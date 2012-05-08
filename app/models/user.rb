class User < ActiveRecord::Base
	has_many :aliases, :autosave => true
end
