require "short_url/version"

module ShortUrl
  module Mixin
    extend ActiveSupport::Concern

    module ClassMethods
      # this is actually an attribute on the class
      attr_reader :short_url_options

      def short_url(column, options = {})
        @short_url_options = options
        @short_url_options[:column] = column
        @short_url_options[:alphabet] ||= %w{ 0 1 2 3 4 5 6 7 8 9 A C E F G H J K M N P Q R T U X Y Z }
        @short_url_options[:mappings] ||= { "O" => "0", "I" => "1", "L" => "1", "S" => "5", "B" => "8", "V" => "U" }
        @short_url_options[:similarity_threshold] ||= 1
        @short_url_options[:length] ||= 7
        @short_url_options[:max_tries] ||= 10
        before_validation :generate_short_url_token, on: :create
      end

      def find_by_short_url(short_url)
        find_by(@short_url_options[:column] => transform_short_url_input(short_url))
      end

      def transform_short_url_input(input)
        input = input.to_s.upcase
        @short_url_options[:mappings].each do |source, target|
          input.gsub!(source, target)
        end
        input
      end
    end

    def generate_short_url_token
      i = 0
      loop do
        send("#{self.class.short_url_options[:column]}=", make_possible_token)
        return true if short_url_is_unique_enough?
        return false if i > self.class.short_url_options[:max_tries]
        i += 0
      end
    end

    def short_url_is_unique_enough?
      self.class.all.each do |obj|
        return false if is_similar?(obj.send(self.class.short_url_options[:column]))
      end

      true
    end

    def make_possible_token
      (0...self.class.short_url_options[:length]).map { self.class.short_url_options[:alphabet].to_a[rand(self.class.short_url_options[:alphabet].size)] }.join
    end

    def is_similar?(other_token)
      delta = 0
      max_size = self.class.short_url_options[:length] - 1
      token = send(self.class.short_url_options[:column])

      (0..max_size).each do |i|
        if token[i] != other_token[i]
          delta += 1
          # If there is more than similarity_threshold change, the tokens are considered different enough.
          return false if delta > self.class.short_url_options[:similarity_threshold]
        end
      end

      true
    end
  end
end


ActiveRecord::Base.send(:include, ShortUrl::Mixin)