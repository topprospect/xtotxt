require 'spec_helper'
require 'xtotxt'

describe Xtotxt do
  before(:all) do
    @input_prefix = "#{Pathname.new(__FILE__).dirname}/fixtures/test"
  end

  before do
    @x = Xtotxt.new
  end

  describe "convert" do

    it "is created with a single hash argument containing convertors" do
      lambda { Xtoxt.new }.should raise_error

      lambda { Xtoxt.new(1, 2) }.should raise_error
    end

    context "input parameters and results" do

      %w{pdf doc docx odt}.each do |ext|
        it "accepts an #{ext} input" do
          lambda { @x.convert("#{@input_prefix}.#{ext}") }.should_not raise_error
        end
      end

      it "does not accept one input file argument of the wrong type" do
         lambda { @x.convert("test.bat") }.should raise_error
      end

    end
  end

  it "converts a pdf document correctly" do
    text = @x.convert("#{@input_prefix}.pdf")

    text.should == "three pigheaded piglets had a plan\n\n\f"
  end

  it "converts a doc document correctly" do
    text = @x.convert("#{@input_prefix}.doc")

    text.should == "\nthree pigheaded piglets had a plan\n\n"
  end

  it "converts a docx document correctly" do
    text = @x.convert("#{@input_prefix}.docx")

    text.should == "three pigheaded piglets had a plan\n\n"
  end

  it "converts a odt document correctly" do
    text = @x.convert("#{@input_prefix}.odt")

    text.should == "\nthree pigheaded piglets had a plan\n\n"
  end

end