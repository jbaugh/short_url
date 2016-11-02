require "short_url/version"
require "short_url/similar"
require "short_url/transformer"
require "short_url/tokenizer"

module ShortUrl
  # def short_url(column, options={})
  #   attr_reader :short_url_options
  #   before_validation :generate_short_url!

  #   @short_url_options = options
  #   @short_url_options[:column] ||= "token"
  #   @short_url_options[:alphabet] ||= %w{ 0 1 2 3 4 5 6 7 8 9 A C E F G H J K M N P Q R T U X Y Z }
  #   @short_url_options[:similarity_threshold] ||= 1
  #   @short_url_options[:length] ||= 7
  #   @short_url_options[:max_tries] ||= 1000

  #   define_method("generate_short_url!") do
  #     token = generate_short_url_token
  #     if token
  #       send("#{@short_url_options[:column]}=", token)
  #     end
  #   end
  # end

  module Mixin
    extend ActiveSupport::Concern

    module ClassMethods
      attr_reader :short_url_options

      def short_url(column, options = {})
        @short_url_options = options
        @short_url_options[:column] = column
        @short_url_options[:alphabet] ||= %w{ 0 1 2 3 4 5 6 7 8 9 A C E F G H J K M N P Q R T U X Y Z }
        @short_url_options[:similarity_threshold] ||= 1
        @short_url_options[:length] ||= 7
        before_validation :generate_short_url_token, on: :create
      end
    end

    def generate_short_url_token
      i = 0
      loop do
        @token = make_possible_token
        return @token if short_url_is_unique_enough?
        return false if i > @short_url_options[:max_tries]
      end
    end

    def short_url_is_unique_enough?
      all.each do |obj|
        return true if is_similar?(@token, obj.send(@short_url_options[:column]))
      end

      false
    end

    def make_possible_token
      (0...@short_url_options[:length]).map { @short_url_options[:alphabet].to_a[rand(@short_url_options[:alphabet].size)] }.join
    end

    def is_similar?(token, other_token)
      delta = 0
      max_size = Url::TOKEN_LENGTH - 1

      (0..max_size).each do |i|
        if token[i] != other_token[i]
          delta += 1
          # If there is more than 1 change, the tokens are considered different enough.
          return false if delta > @short_url_options[:similarity_threshold]
        end
      end

      true
    end
  end
end


# ActiveSupport.on_load(:active_record) do
#   extend ShortUrl
# end
ActiveRecord::Base.send(:include, ShortUrl::Mixin)