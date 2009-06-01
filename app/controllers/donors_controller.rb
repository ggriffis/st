class DonorsController < BaseController
  
  def new
    @donor = Donor.new

    respond_to do |format|
      format.html # new.html.haml
      format.xml  { render :xml => @donor }
    end
  end
  
  def show
    @clippings      = @user.clippings.find(:all, :limit => 5)
    @photos         = @user.photos.find(:all, :limit => 5)

    @savers = []
    if @donor.donations_given
      @donor.donations_given.each do |donation|
        @savers << donation.saver
      end
    end
  end

  def create
    @donor       = Donor.new(params[:donor])
    @donor.role  = Role[:member]
    @donor.birthday = 18.years.ago

    donation_id = params[:donation_id]
    if (!AppConfig.require_captcha_on_signup || verify_recaptcha(@donor)) && @donor.save
      # If a donation_id is supplied, we add it to the user's donation list
      unless donation_id.blank?
        donation = Donation.find(donation_id)
        if !donation.donor
          donation.donor = @donor
          donation.save
        end
      end
      #create_friendship_with_inviter(@user, params)
      flash[:notice] = :email_signup_thanks.l_with_args(:email => @donor.email)
      redirect_to signup_completed_user_path(@donor)
    else
      render :action => 'new'
    end
  end
end
