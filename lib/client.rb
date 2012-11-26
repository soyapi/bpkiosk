#
# Users of the BP Kiosk
#
class Client < ActiveRecord::Base
  MIN_NUM = 2430000    # to prevent ids with leading zeroes
  
  def self.add
    number = NationalPatientId.new(MIN_NUM + Client.count).value
    Client.create :client_number => number
  end
  
  def to_s
    NationalPatientId.new(self.client_number, 30).to_s
  end
  
  def number_label
    label = ZebraPrinter::StandardLabel.new
    label.font_size = 2
    label.font_horizontal_multiplier = 2
    label.font_vertical_multiplier = 2
    label.left_margin = 50
    label.draw_barcode(50,180,0,1,5,15,120,false, self.client_number)
    label.draw_multi_text("BP Kiosk")
    #label.draw_multi_text(" ")
    label.draw_multi_text(self.to_s)
    label.print
  end
end