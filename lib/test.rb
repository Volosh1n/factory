require_relative 'factory'

Customer = Factory.new(:name, :address, :zip)

joe = Customer.new('Joe Smith', '123 Maple, Anytown NC', 12345)

puts joe.name
puts joe['name']
puts joe[:name]
puts joe[0]

Customer1 = Factory.new(:name, :address) do
  def greeting
    "Hello #{name}!"
  end
end

puts Customer1.new('Dave', '123 Main').greeting
