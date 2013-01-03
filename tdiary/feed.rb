require 'rss'

module TDiary
  class Feed < Application
    def call(env)
      request = adopt_rack_request_to_plain_old_tdiary_style(env)
      conf = Config.new(CGI.new, request)
      tdiary = TDiaryLatest.new(CGI.new, nil, conf)
      io = conf.io_class.new(tdiary)

      articles = []
      count = 0
      io.calendar.reverse_each do |year, months|
        months.reverse_each do |month|
          io.transaction(Date.new(year.to_i, month.to_i)) do |diaries|
            diaries.reverse_each do |date, article|
              if article.visible? and count < 15
                articles << article
                count += 1
              end
              TDiaryBase::DIRTY_DIARY
            end
          end
          break if count >= 15
        end
        break if count >= 15
      end

      feed = RSS::Maker.make(@target) {|maker|
        maker.channel.about = conf['makeatom.url'] || "#{conf.base_url}recent.atom"
        maker.channel.title = conf.html_title
        maker.channel.author = conf.author_name
        maker.channel.description = conf.description || ''
        maker.channel.link = conf.base_url
        maker.channel.updated = articles.first.last_modified

        articles.each do |article|
          maker.items.new_item do |item|
            item.link = "#{conf.base_url}?date=#{article.date.strftime('%Y%m%d')}"
            item.title = article.title
            item.published = article.date
            item.updated = article.last_modified
            item.description = article.to_html
          end
        end
      }

      Response.new([feed.to_s], 200, {'Content-Type' => 'application/atom+xml'})
    end
  end
end
