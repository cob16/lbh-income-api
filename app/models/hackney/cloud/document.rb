module Hackney
  module Cloud
    class Document < ApplicationRecord
      enum status: { uploading: 0, uploaded: 1, received: 2, accepted: 3, failed: 4 }
    end
  end
end
