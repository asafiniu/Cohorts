class User < ActiveRecord::Base
    has_many :orders

    def first_order
        return self.orders.first
    end
end
