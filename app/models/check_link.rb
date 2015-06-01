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
		@link_stack = Array.new
		@end_flag = false
		@hostname = ''
	end

    
  def get_all_links(model_check_link)
    #Get only the hostname to compare afterwards
    @hostname = get_host_without_www(model_check_link)
    #Get links for the first page
    links = get_links_for_single_link(model_check_link)
    links.each do |link1|
      #Ignore the link if https
      if link1.include? 'https'
          next
      end
      if @links_hash.key?(link1)
        @links_hash[link1] += 1
      else
        @links_hash[link1] = 1
        #Put all the domain matching links on the stack
        if get_host_without_www(link1).include? @hostname
          @link_stack.push(link1)
        end  
      end
    end
    puts @links_hash.length 
    puts @link_stack.length
    #Loop through the stack until the stack is empty to get all the links 
    #that needs to be visited
    until @link_stack.empty?
      new_link = @link_stack.pop()
      links = get_links_for_single_link(new_link)
      links.each do |link2|
        if link2.include? 'https'
          next
        end
        if @links_hash.key?(link2)
          @links_hash[link2] += 1
        else
          @links_hash[link2] = 1
          #Put all the domain matching links on the stack
          if get_host_without_www(link2).include? @hostname
            @link_stack.push(link2)
          end
        end  
      end
    end
      
  puts @links_hash.length     
  puts @link_stack.length
  end

	private
		def get_links_for_single_link(link)
		  begin
		    res = RestClient.get(link)
		    page = Nokogiri::HTML(res) 
        links = page.css("a")
        hrefs = links.map {|link3| link3.attribute('href').to_s}.uniq.sort.delete_if {|href| href.empty?}
        return hrefs
      rescue
          @error_links[link] = '800'
          return []
		  end
		end

		def get_host_without_www(url)
		  begin
		    uri = URI.parse(url)
        uri = URI.parse("http://#{url}") if uri.scheme.nil?
        host = uri.host.downcase
        host.start_with?('www.') ? host[4..-1] : host
      rescue
        return 'false'
		  end
		end

end