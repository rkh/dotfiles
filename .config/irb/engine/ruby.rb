module MyIRB

  def get_source an_object
    case an_object
    when String then an_object
    when Module then Ruby2Ruby.translate object
    when Method then Ruby2Ruby.translate object.owner, object.name
    else raise ArgumentError, "Don't know how to get source of #{an_object}"
    end
  end

end