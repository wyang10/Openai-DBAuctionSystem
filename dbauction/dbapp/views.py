from django.contrib.auth import authenticate, login, logout
from django.db import IntegrityError
from django.http import HttpResponse, HttpResponseRedirect
from django.shortcuts import render
from django.urls import reverse

from .models import User, Auction, Bid, Category, Comment, Watchlist
from .forms import NewCommentForm, NewListingForm, NewBidForm
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.core.exceptions import ObjectDoesNotExist

# use category to test the function
def testmysql(request):
    category = Category.objects.all()
    context = {
        'title': category[0].title,
    }
    return render(request, 'home.html', context)

# render the home page, showing all action items ordered by creation date
def index(request):
    return render(request, "dbapp/index.html", {
        "auctions": Auction.objects.filter(closed=False).order_by('-creation_date')
    })


def login_view(request):
    if request.method == "POST":

        # Sign user in with authenticate libraty
        username = request.POST["username"]
        password = request.POST["password"]
        user = authenticate(request, username=username, password=password)

        # Check if user in our database
        if user is not None:
            login(request, user)
            # set sucessful message with message library
            messages.success(request, f'Welcome, {username}. Login successfully.')

            return HttpResponseRedirect(reverse("index"))
        else:
            return render(request, "dbapp/login.html", {
                "message": "Invalid username and/or password."
            })
    else:
        return render(request, "dbapp/login.html")


def logout_view(request):
    logout(request)
    return HttpResponseRedirect(reverse("index"))


def register(request):
    if request.method == "POST":
        # get user info
        username = request.POST["username"]
        email = request.POST["email"]

        # make sure password is consistent
        password = request.POST["password"]
        confirmation = request.POST["confirmation"]
        # if not prompt to user with message
        if password != confirmation:
            return render(request, "dbapp/register.html", {
                "message": "Not matching record: passwords must match."
            })

        # create new user, save in our database
        try:
            user = User.objects.create_user(username, email, password)
            user.save()
        except IntegrityError:
            return render(request, "dbapp/register.html", {
                "message": "Username already taken."
            })
        login(request, user)
        return HttpResponseRedirect(reverse("index"))
    else:
        return render(request, "dbapp/register.html")

# show all available categories
def categories(request):
    return render(request, "dbapp/categories.html", {
        "categories": Category.objects.all()
    })

# show all auction items under specific category
def category(request, category_id):
    try:
        # list all available auction items under a specific category
        auctions = Auction.objects.filter(category=category_id, closed=False).order_by('-creation_date')
         
    except Auction.DoesNotExist:
        return render(request, "dbapp/error.html", {
            "code": 404,
            "message": f"Not exist: the current category."
        })
   
    try:
        # get specific category
        category = Category.objects.get(pk=category_id)

    except Category.DoesNotExist:
        return render(request, "dbapp/error.html", {
            "code": 404,
            "message": f"The category does not exist."
        })

    return render(request, "dbapp/category.html", {
        "auctions": auctions,
        "category": category
    })


@login_required(login_url="login") 
def watchlist(request):
    # check if user has specific watchlist
    try:
        watchlist = Watchlist.objects.get(user=request.user)
        auctions = watchlist.auctions.all().order_by('-id')
        # count the number of auctions items in the user's watchlist
        watchingNum = watchlist.auctions.all().count()

    except ObjectDoesNotExist:
        # if watchlist does not exist
        watchlist = None
        auctions = None
        watchingNum = 0
    

    return render(request, "dbapp/watchlist.html", {
        # list all items in the watchlist
        "watchlist": watchlist,
        "auctions": auctions,
        "watchingNum": watchingNum
    })


@login_required(login_url="login")
def create(request):
    # check the request method is POST
    if request.method == "POST":
        # create a new listing form
        form = NewListingForm(request.POST, request.FILES)

        # check whether it's valid
        if form.is_valid():
            # stores the form into our model
            new_listing = form.save(commit=False)
            # store the request user as seller
            new_listing.seller = request.user
            # store the starting bid as current price
            new_listing.current_bid = form.cleaned_data['starting_bid']
            new_listing.save()

            # return the sucessful message
            messages.success(request, 'Success: auction item created')

            # redirect the user back to our index page
            return HttpResponseRedirect(reverse("index"))

        else:
            form = NewListingForm()

            # if the form is invalid, re-render the page with existing form
            messages.error(request, 'The form is invalid. Please resumbit.')
            return render(request, "dbapp/create.html", {
                "form": form
            })
    
    # if the request method is GET
    else:
        form = NewListingForm()
        return render(request, "dbapp/create.html", {
            "form": form
        })


def listing(request, auction_id):  
    try:
        # fetch the auction items list by auction id
        auction = Auction.objects.get(pk=auction_id)
        
    except Auction.DoesNotExist:
        return render(request, "dbapp/error.html", {
            "code": 404,
            "message": "The auction does not exist."
        })

    # default watching flag 
    watching = False
    # default highest bidder   
    highest_bidder = None

    # check if the auction in the watchlist
    if request.user.is_authenticated and Watchlist.objects.filter(user=request.user, auctions=auction):
        watching = True
    
    # get current user
    user = request.user

    # get number of bids
    bid_Num = Bid.objects.filter(auction=auction_id).count()

    # get the item's comments
    comments = Comment.objects.filter(auction=auction_id).order_by("-cm_date")

    # get the auction highest bid
    highest_bid = Bid.objects.filter(auction=auction_id).order_by("-bid_price").first()
    
    # check the request method is POST
    if request.method == "GET":
        form = NewBidForm()
        commentForm = NewCommentForm()

        # check if the item bidding status
        if not auction.closed:
            return render(request, "dbapp/listing.html", {
            "auction": auction,
            "form": form,
            "user": user,
            "bid_Num": bid_Num,
            "commentForm": commentForm,
            "comments": comments,
            "watching": watching
            }) 

        # if it's closed
        else:
            # check if there exists highest bid
            if highest_bid is None:
                messages.info(request, 'Current item bidding is closed.')

                return render(request, "dbapp/listing.html", {
                    "auction": auction,
                    "form": form,
                    "user": user,
                    "bid_Num": bid_Num,
                    "highest_bidder": highest_bidder,
                    "commentForm": commentForm,
                    "comments": comments,
                    "watching": watching
                })

            else:
                # set the highest_bidder
                highest_bidder = highest_bid.bider

                # check the current if the bid winner    
                if user == highest_bidder:
                    messages.info(request, 'Congrats! You had won the bid!')
                else:
                    messages.info(request, f'Winner is: {highest_bidder.username}')

                return render(request, "dbapp/listing.html", {
                "auction": auction,
                "form": form,
                "user": user,
                "highest_bidder": highest_bidder,
                "bid_Num": bid_Num,
                "commentForm": commentForm,
                "comments": comments,
                "watching": watching
                })

    
    # not allow the post 
    else:
        return render(request, "dbapp/error.html", {
            "code": 405,
            "message": "The POST method is not allowed."
        })
        
        

@login_required(login_url="login")
def close(request, auction_id):
    if request.method == "POST":
        try:
            # get item id
            auction = Auction.objects.get(pk=auction_id)

        except Auction.DoesNotExist:
            return render(request, "dbapp/error.html", {
                "code": 404,
                "message": "The auction does not exist."
            })

        # check if the current user is the seller
        if request.user != auction.seller:
            messages.error(request, 'The request is not allowed.')
            return HttpResponseRedirect(reverse("listing", args=(auction.id,)))

        else:
            # update the status
            auction.closed = True
            auction.save()
            
            # prompt with the  message
            messages.success(request, 'Success: auction list closed')
            return HttpResponseRedirect(reverse("listing", args=(auction.id,)))
    
    else:
        return render(request, "dbapp/error.html", {
            "code": 405,
            "message": "The GET method is not allowed."
        })
        

@login_required(login_url="login")
def bid(request, auction_id):  
    if request.method == "POST":
        try:
            # fetch auction item with id
            auction = Auction.objects.get(pk=auction_id)     
            
        except Auction.DoesNotExist:
            return render(request, "dbapp/error.html", {
                "code": 404,
                "message": "The auction does not exist."
            })

        # fetch the highest bid
        highest_bid = Bid.objects.filter(auction=auction_id).order_by("-bid_price").first()
        if highest_bid is None:
            highest_bid_price = auction.current_bid
        else:
            highest_bid_price = highest_bid.bid_price

        # generate a new bid form
        form = NewBidForm(request.POST, request.FILES)

        # if auction is closed
        if auction.closed is True:
            messages.error(request, 'Closed the auction')
            return HttpResponseRedirect(reverse("listing", args=(auction.id,))) 
        
        # the auction item is still active
        else:
            if form.is_valid():
                # create an isolated environment for a clean version of form data
                bid_price = form.cleaned_data["bid_price"]

                # check if it is the highest bid price so far
                if bid_price > auction.starting_bid and bid_price > (auction.current_bid or highest_bid_price):
                    # store the data
                    new_bid = form.save(commit=False)
                    # save the request user as new bider
                    new_bid.bider = request.user
                    # store the auction item
                    new_bid.auction = auction
                    new_bid.save()

                    # update the bid price
                    auction.current_bid = bid_price
                    auction.save()

                    # return a sucessful message
                    messages.success(request, 'Success: Bid offered.')

                # if the bid offer is invalid
                else:
                    messages.error(request, 'Please submit a valid bid offer. Your bid offer must be higher than the starting bid and current price.')

                return HttpResponseRedirect(reverse("listing", args=(auction.id,)))    

            else:
                messages.error(request, 'Please submit a valid bid offer. Your bid offer must be higher than the starting bid and current price.')
                return HttpResponseRedirect(reverse("listing", args=(auction.id,)))
    
    else:
        return render(request, "dbapp/error.html", {
            "code": 405,
            "message": "The GET method is not allowed."
        })


@login_required(login_url="login")
def comment(request, auction_id):
    if request.method == "POST":
        try:
            # fetch auction item with id
            auction = Auction.objects.get(pk=auction_id)     
            
        except Auction.DoesNotExist:
            return render(request, "dbapp/error.html", {
                "code": 404,
                "message": "The auction does not exist."
            })
            
        # generate a new form with POST data
        form = NewCommentForm(request.POST, request.FILES)

        if form.is_valid():
            # save data 
            new_comment = form.save(commit=False)
            # save the user who made the comment
            new_comment.user = request.user
            # save the auction item
            new_comment.auction = auction
            new_comment.save()

            # return a sucessful message
            messages.success(request, 'Successfully commented.')

            return HttpResponseRedirect(reverse("listing", args=(auction.id,)))
        
        # if the form is invalid
        else:
            messages.error(request, 'The comment is invalid. Please submit a valid comment again.')
     
    else:
        return render(request, "dbapp/error.html", {
            "code": 405,
            "message": "The GET method is not allowed."
        })


@login_required(login_url="login")
def addWatchlist(request, auction_id):   
    if request.method == "POST":
        try:
            # fetch the auction item with its id
            auction = Auction.objects.get(pk=auction_id)     
            
        except Auction.DoesNotExist:
            return render(request, "dbapp/error.html", {
                "code": 404,
                "message": "The auction does not exist."
            })

        # check if user has created his/her watchlist
        try:
            watchlist = Watchlist.objects.get(user=request.user)

        except ObjectDoesNotExist:
            # create a new watchlist if it doesn't exist
            watchlist = Watchlist.objects.create(user=request.user)
        
        # check if the item exists already
        if Watchlist.objects.filter(user=request.user, auctions=auction):
            messages.error(request, 'Item is already in your watchlist')
            return HttpResponseRedirect(reverse("listing", args=(auction.id,)))

        # if the item not exists
        watchlist.auctions.add(auction)
            
        # return a sucessful message
        messages.success(request, 'Added list into your watchlist.')

        return HttpResponseRedirect(reverse("listing", args=(auction.id,)))
        
    else:
        return render(request, "dbapp/error.html", {
            "code": 405,
            "message": "The GET method is not allowed."
        })


@login_required(login_url="login")
def removeWatchlist(request, auction_id):   
    if request.method == "POST":
        try:
            # fetch the auction item with its id
            auction = Auction.objects.get(pk=auction_id)     
            
        except Auction.DoesNotExist:
            return render(request, "dbapp/error.html", {
                "code": 404,
                "message": "The auction does not exist."
            })
        
        # check if the item already exists in the watchlist
        if Watchlist.objects.filter(user=request.user, auctions=auction):
            # fetch the user's watchlist
            watchlist = Watchlist.objects.get(user=request.user)
           
            # delete the item from the users watchlist
            watchlist.auctions.remove(auction)
                
            # return a sucessful message
            messages.success(request, 'Removed the item from your watchlist.')

            return HttpResponseRedirect(reverse("listing", args=(auction.id,)))
        
        else:
            # return an error message
            messages.success(request, 'Removing the item from your watchlist failed')

            return HttpResponseRedirect(reverse("listing", args=(auction.id,)))
   
    else:
        return render(request, "dbapp/error.html", {
            "code": 405,
            "message": "The GET method is not allowed."
        })










