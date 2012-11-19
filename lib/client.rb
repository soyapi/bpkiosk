#
# Users of the BP Kiosk
#
class Client < ActiveRecord::Base
  MIN_NUM = 2430000    # to prevent ids with leading zeroes
  
  def self.add
    number = NationalPatientId.new(MIN_NUM + Client.count).value
    Client.create :client_number => number
  end
end