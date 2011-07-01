require 'spec_helper'

describe Jenkins::Plugins::Proxies do
  before {@proxies = Jenkins::Plugins::Proxies.new}

  it "lives" do
    @proxies.wrappers.should be_empty
  end

  describe "exporting a native ruby object" do

    describe "when no wrapper exists for it" do

    end

    describe "when a wrapper has already existed" do

    end

    describe "when a wrapper had been created, but was garbage collected" do

    end
  end
end
