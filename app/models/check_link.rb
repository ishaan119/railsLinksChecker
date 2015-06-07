require 'rubygems'
require 'nokogiri'
require 'rest_client'
require "set"
require 'typhoeus'

class CheckLink < ActiveRecord::Base
  validates :checked_url, presence: true
	
	
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
      if link1.include? 'https' or link1.include? 'jpg' or link1.include? 'gif' or link1.include? 'mailto'
          next
      end
      
      #if link starts with / then append hostname
      if link1.start_with? '/'
          link1 = 'http://www.' + @hostname + link1
      end 
      
      if @links_hash.key?(link1)
        @links_hash[link1] += 1
      else
        @links_hash[link1] = 1
        #Put all the domain matching links on the stack
        if get_host_without_www(link1) == @hostname
          @link_stack.push(link1)
        end  
      end
    end
    puts @links_hash.length 
    puts @link_stack.length
    
    
    #Loop through the stack until the stack is empty to get all the links 
    #that needs to be visited
    until @link_stack.empty?
      puts @link_stack.length
      new_link = @link_stack.pop()
      puts new_link
      if new_link.start_with? '/'
        new_link = 'http://www.' + @hostname + new_link
      end
      
      links = get_links_for_single_link(new_link)
      links.each do |link2|
        if link2.include? 'https' or link2.include? 'jpg' or link2.include? 'gif' or link2.include? 'mailto'
          next
        end
        if link2.start_with? '/'
            link2 = 'http://www.' + @hostname + link2
        end
        
        if @links_hash.key?(link2)
          @links_hash[link2] += 1
        else
          @links_hash[link2] = 1
          #Put all the domain matching links on the stack
          if get_host_without_www(link2) == @hostname
            @link_stack.push(link2)
          end
        end  
      end
    end
      
  puts @links_hash.length     
  puts @link_stack.length
  
  start_checking()
  puts @error_links.length
  
  @error_links.each do |key,value|
    puts key
  end
  
  self.errors_found = @error_links.length
  self.checked_url = model_check_link
  
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
		
		def start_checking()
		  hydra = Typhoeus::Hydra.new
		  successes = 0
		  fail = 0
		  @links_hash.each do |url,value|
        request = Typhoeus::Request.new(url,followlocation: true)
        request.on_complete do |response|
           if response.success?
               successes += 1
           elsif response.timed_out?
               # aw hell no
               puts "got a time out"
           elsif response.code == 0
               # Could not get an http response, something's wrong.
               puts response.return_message
           else
               @error_links[url] = response.code
           end
          end
        hydra.queue(request)
		  end
		  puts 'Started running'
		  hydra.run 
		end

end