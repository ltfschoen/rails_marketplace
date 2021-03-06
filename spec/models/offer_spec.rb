require 'rails_helper'

RSpec.describe Offer, type: :model do
  #Associations
  it { should belong_to(:listing) }
  it { should belong_to(:user) }

  #Association validations
  it { should validate_presence_of(:listing) }
  it { should validate_presence_of(:user) }

  #Attribute validations
  it { should validate_presence_of(:price).with_message("Your offer must have a price!") }

	let!(:user_one) { FactoryGirl.create(:user, :ben) }
	let!(:user_two) { FactoryGirl.create(:user, :bob) }
	let!(:category) {FactoryGirl.create(:category) }
	let(:listing) { FactoryGirl.create(:listing, category: category, user: user_one) }
	let(:offer) { FactoryGirl.create(:offer, user: user_two, listing: listing) }

  it "cannot be created without a user, a listing & a price" do
 		expect{ Offer.create(price: 4.99, listing: listing)}.not_to change{Offer.count}
  end

 	it "will be created with a user, a listing & a price" do
 		expect{ Offer.create(price: 4.99, user: user_two, listing: listing)}.to change{Offer.count}
  end

  context "offer status changes" do
    it "changes status to accepted when offer_accepted" do
      expect { offer.accept_offer! }.to change(offer, :status).from('made').to('accepted')
    end

    it "changes status to declined when offer_declined" do
      expect { offer.decline_offer! }.to change(offer, :status).from('made').to('declined')
    end

    it "changes status to withdrawn when offer_withdrawn" do
      expect { offer.withdraw_offer! }.to change(offer, :status).from('made').to('withdrawn')
    end

    it "changes status to lapsed when offer_lapsed" do
      expect { offer.offer_lapsed! }.to change(offer, :status).from('made').to('lapsed')
    end
  end

  context "offer status" do
    it 'offer has a status of "made" by default' do
      expect(offer.status).to eq ("made")
    end

    it 'offer is invalid if status is not found within Offer::STATES' do
      offer.status = "bob"
      expect(offer).to_not be_valid
      expect(offer.errors[:status]).to include "is not included in the list"
    end

    it 'offer is invalid if status is blank' do
      offer.status = nil
      expect(offer).to_not be_valid
      expect(offer.errors[:status]).to include "is not included in the list"
    end

    it 'offer status will change from made to cancelled if seller does not respond in 24hrs' do
      offer.status = "made"
      #Something with Timecop
    end
  end

  context 'as a buyer' do
	  context 'making an offer' do
	    it 'is accepted if offer is valid price' do
	    	offer.price = 4.99
	    	expect(offer).to be_valid
	    end

	    it 'raises an error if offer is not a valid price' do
	    	offer.price = "bob"
        offer.save
	    	expect(offer).to_not be_valid
	    end

      it 'raises an error if the buyer is the listing owner' do
        expect { FactoryGirl.create(:offer, user: user_one, listing: listing) }.to raise_error "You cannot make an offer on your own listing."
      end

	    xit 'user cannot make a new offer if they currently have an existing offer live offer on the listing' do
        #this is breaking all the other specs - need to refactor the Factories.
				expect{ FactoryGirl.create(:offer, user: user_two, listing: listing) }.to raise_error('You already have a live offer on this listintg.')
	    end

      #Massive refactor required - this is horrible.
      let(:listing_two) { FactoryGirl.create(:listing, category: category, user: user_one) }
      let(:listing_three) { FactoryGirl.create(:listing, category: category, user: user_one) }
      let(:listing_four) { FactoryGirl.create(:listing, category: category, user: user_one) }
      let(:listing_five) { FactoryGirl.create(:listing, category: category, user: user_one) }
      let(:listing_six) { FactoryGirl.create(:listing, category: category, user: user_one) }

	    it 'raises an error if user has more than or equal to 5 live offers' do
        FactoryGirl.create(:offer, price: 4.99, user: user_two, listing: listing)
        FactoryGirl.create(:offer, price: 4.99, user: user_two, listing: listing_two)
        FactoryGirl.create(:offer, price: 4.99, user: user_two, listing: listing_three)
        FactoryGirl.create(:offer, price: 4.99, user: user_two, listing: listing_four)
        FactoryGirl.create(:offer, price: 4.99, user: user_two, listing: listing_five)
	    	expect { Offer.create(price: 4.99, user: user_two, listing: listing_six) }.to raise_error('You cannot have more than 5 live offers at any one time.')
	    end

      before do


      end

      xit 'raises an error if user has already made 3 offers on a listing' do
        #place the setup of this into a spec helper method somewhere
        expect{ FactoryGirl.create(:offer, user: user_two, listing: listing) }.to raise_error('You have already made 5 offers on this listing.')
      end

	  end

	  context 'viewing your offers' do

  	end

  	context 'cancelling your offer' do

  	end

  end

  context 'as a seller' do
  	context 'viewing your offers' do

  	end

  	context 'accepting offers' do
  		it "changes offer status to accepted when seller accepts offer within 24hrs" do

  		end
  	end

  	context 'declining offers' do
  		it "changes offer status to declined when seller declines offer within 48hrs" do

  		end
  	end
  end

  describe "#find_duplicate_offer" do
    it "returns made (i.e. active) duplicate offers" do

    end
  end

end
