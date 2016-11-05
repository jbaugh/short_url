require 'spec_helper'

describe ShortUrl do
  describe ".transform_short_url_input" do
    it "capitalizes input" do
      expect(Url.transform_short_url_input("ghk")).to eq("GHK")
      expect(Url.transform_short_url_input("GhK")).to eq("GHK")
      expect(Url.transform_short_url_input("GHK")).to eq("GHK")
    end

    it "removes ambiguity between common characters" do
      expect(Url.transform_short_url_input("A0C")).to eq("A0C")
      expect(Url.transform_short_url_input("AOC")).to eq("A0C")
      expect(Url.transform_short_url_input("AoC")).to eq("A0C")
      expect(Url.transform_short_url_input("AIC")).to eq("A1C")
      expect(Url.transform_short_url_input("A1C")).to eq("A1C")
      expect(Url.transform_short_url_input("AlC")).to eq("A1C")
      expect(Url.transform_short_url_input("ALC")).to eq("A1C")
      expect(Url.transform_short_url_input("AiC")).to eq("A1C")
      expect(Url.transform_short_url_input("A5C")).to eq("A5C")
      expect(Url.transform_short_url_input("AsC")).to eq("A5C")
      expect(Url.transform_short_url_input("ASC")).to eq("A5C")
      expect(Url.transform_short_url_input("ABC")).to eq("A8C")
    end

    it "maps a list of characters to un-ambiguous characters" do
      Url.short_url_options[:mappings].each do |old_char, new_char|
        expect(Url.transform_short_url_input("A#{old_char}C")).to eq("A#{new_char}C") 
      end
    end
  end

  it 'has a version number' do
    expect(ShortUrl::VERSION).not_to be nil
  end
end


# require "rails_helper"

# describe InputTransformer do
#   it "capitalizes the input" do
#     expect(InputTransformer.transform("acd")).to eq("ACD")
#   end

#   it "removes ambiguity between 0 and O" do
#     expect(InputTransformer.transform("AOC")).to eq("A0C")
#   end

#   it "removes ambiguity between I and 1" do
#     expect(InputTransformer.transform("AIC")).to eq("A1C")
#   end

#   it "removes ambiguity between l and 1" do
#     expect(InputTransformer.transform("AlC")).to eq("A1C")
#   end

#   it "removes ambiguity between S and 5" do
#     expect(InputTransformer.transform("ASC")).to eq("A5C")
#   end

#   it "removes ambiguity between B and 8" do
#     expect(InputTransformer.transform("ABC")).to eq("A8C")
#   end

#   it "removes ambiguity between V and U" do
#     expect(InputTransformer.transform("AVC")).to eq("AUC")
#   end

#   it "produces consistent output for different cases" do
#     str = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
#     expect(InputTransformer.transform(str)).to eq(InputTransformer.transform(str.downcase))
#   end

#   it "is idempotent" do
#     str = InputTransformer.transform("AOB81IL019MJDO3")
#     expect(InputTransformer.transform(str)).to eq(str)
#   end
# end
