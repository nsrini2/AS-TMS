class Array

  def histogram
    self.sort.inject({}){|a,x|a[x]=a[x].to_i+1;a}
  end

end

class TagCloud

  def self.tagcloudize(array)
     return [] if array.blank?
     distribution=array.histogram
     max=distribution.max_by{|a,b|b}[1]
     distribution.map do |text,count|
        if block_given?
           size=yield(count,max)
        else
           size=TagCloud.default_formula(count,max)
        end
     {:text => text, :count => count, :size => size}
    end
  end

 def self.default_formula(count,max)
    90 + 110 *(count/max.to_f)
 end

end







