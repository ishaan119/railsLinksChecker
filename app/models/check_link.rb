require 'rubygems'
require 'nokogiri'
require 'rest_client'
require "set"
require 'thread'

class CheckLink < ActiveRecord::Base

	def initialize()
		#in rails when you need to use your own initialize you need to use super
		super
		@links_hash = Hash.new
		@links_visited = Hash.new
		@error_links = Hash.new
		puts 'In here'
	end

	
	def get_all_links(model_check_link='www.aylanetworks.com')
		links = get_links_for_single_link(model_check_link)
		puts links.class
		links.each do |link1|
			if @links_hash.key?(link1)
				@links_hash[link1] += 1
			else
				@links_hash[link1] = 1
			end
		end

		#Now I have a Base hash to start working with
		



	end

	private
		def get_links_for_single_link(link)
			page = Nokogiri::HTML(RestClient.get(link)) 
			links = page.css("a")
			return links
		end

		def get_host_without_www(url)
  			uri = URI.parse(url)
			uri = URI.parse("http://#{url}") if uri.scheme.nil?
			host = uri.host.downcase
			host.start_with?('www.') ? host[4..-1] : host
		end


end
