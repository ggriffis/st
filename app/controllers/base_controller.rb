class BaseController < ApplicationController
  def site_index
    @successful_saver = SAVER_FEATURED_SUCCESSFUL_SAVER # TODO (dscott) replace this with a new Saver.featured_successful_saver call
    @featured_savers  = Saver.featured_savers(3)
    @partner_list     = random_partner_list

    # DPIRONE: note this does a lot of extra work to get CE meta data that we presently don't use,
    # so commenting out to save CPU cycles ...
    # respond_to do |format|
      # format.html { get_additional_homepage_data }
    # end
  end

protected

  def random_partner_list
    founders = random_truth?
    OpenStruct.new(
      :partners_kind => founders ? "Founding Partners"                     : "Supporters"                     ,
      :partners      => founders ?  ORGANIZATION_FIND_BY_FOUNDING_PARTNERS :  ORGANIZATION_FIND_BY_SUPPORTERS
      # TODO (dscott) replace constants above with new Organization.find_by_foundering_partners, .find_by_supporters
    )
  end
  
  def random_truth?
    # rand(2) returns a psuedorandom integer >= 0 and less than max=2 (in this case), i.e 0 or 1
    # See Kernel.rand, Pickaxe book, pg. 527.
    rand(2) == 1
  end

end
