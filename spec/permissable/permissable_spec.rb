require File.dirname(__FILE__) + '/../spec_helper'

describe "permissable" do
  context "argument parsing" do
    before(:all) do
      @obj1 = mock("empty object")
      @obj1.should_receive(:class).and_return("User")
      @obj1.should_receive(:id).and_return(10)
      @obj1.should_receive(:is_a?).and_return(true)
      
      @obj2 = mock("empty object")
      @obj2.should_receive(:class).and_return("Project")
      @obj2.should_receive(:id).and_return(99)
      @obj2.should_receive(:is_a?).and_return(true)
      
      @name1 = Jamlab::Permissable::ArgumentParser.new("admin_can_be_edited_by?", @obj2, @obj1)
      @name2 = Jamlab::Permissable::ArgumentParser.new("admin_can_be_bitch_slapped_by!", nil, nil)
      @name3 = Jamlab::Permissable::ArgumentParser.new("can_admin_admins?", @obj1, @obj2)
      @name4 = Jamlab::Permissable::ArgumentParser.new("can_scream_in_pain!", @obj1, ["Gimp", -1])
      @name5 = Jamlab::Permissable::ArgumentParser.new("can_be_edited_by!", nil, nil)
      @name6 = Jamlab::Permissable::ArgumentParser.new("can_not_dry_heave!", nil, nil)
      @invalid1 = Jamlab::Permissable::ArgumentParser.new("this_is_gibberish!", nil, nil)
    end

    it "should detect queries" do
      @name1.should_not be_assigning
    end

    it "should detect assignments" do
      @name2.should be_assigning
    end
  
    it "should handle the normal order" do
      @name3.should_not be_reversed
    end

    it "should handle reversed order" do
      @name5.should be_reversed
    end

    it "should normally return false for #is_negated?" do
      @name3.should_not be_negated
    end

    it "should handle negated calls" do
      @name6.should be_negated
    end

    it "should not accept admin for queries" do
      @name1.should_not be_admin
    end

    it "should detect admin assignment methods" do
      @name2.should be_admin
    end

    it "should detect invalid methods" do
      @invalid1.should_not be_valid
    end

    it "should find the action name" do
      @name3.action.should == "admin_admins"
    end

    it "should find multi-word action names" do
      @name4.action.should == "scream_in_pain"
    end

    it "should normalize the action names" do
      @name5.action.should == "edit"
    end
    
    it "should get controllable array" do
      @name3.controllable.should == ["User", 10]
    end
    
    it "should get controllable array through a reversed call" do
      @name1.controllable.should == ["User", 10]
    end
    
    it "should get accessible array" do
      @name3.accessible.should == ["Project", 99]
    end
    
    it "should get accessible array through a reversed call" do
      @name1.accessible.should == ["Project", 99]
    end
    
    it "should handle passed pairs" do
      @name4.accessible.should == ["Gimp", -1]
    end
    
    it "should return a fully formed argument array" do
      @name1.args.should == ["User", 10, "Project", 99]
    end
  end
end
