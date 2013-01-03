require 'rss'

module TDiary
  class Feed < Application
    ENTRY_COUNT = 15

    def call(env)
      request = adopt_rack_request_to_plain_old_tdiary_style(env)
      conf = Config.new(CGI.new, request)
      tdiary = TDiaryLatest.new(CGI.new, nil, conf)
      @io = conf.io_class.new(tdiary)

      entries = entries(ENTRY_COUNT)
      feed = RSS::Maker.make(@target) {|maker|
        maker.channel.about = conf['makeatom.url'] || "#{conf.base_url}recent.atom"
        maker.channel.title = conf.html_title
        maker.channel.author = conf.author_name
        maker.channel.description = conf.description || ''
        maker.channel.link = conf.base_url
        maker.channel.updated = entries.first.last_modified

        entries.each do |entry|
          maker.items.new_item do |item|
            item.link = "#{conf.base_url}?date=#{entry.date.strftime('%Y%m%d')}"
            item.title = entry.title
            item.published = entry.date
            item.updated = entry.last_modified
            item.description = entry.to_enum(:each_section).map {|section| '<div class="section">' << section.body_to_html << '</div>'}.join
          end
        end
      }

      Response.new([feed.to_s], 200, {'Content-Type' => 'application/atom+xml', 'Last-Modified' => entries.first.last_modified.httpdate})
    end

    private

    def entries(limit=DEFAULT_COUNT)
      entries = []
      count = 0
      @io.calendar.reverse_each do |year, months|
        months.reverse_each do |month|
          @io.transaction(Date.new(year.to_i, month.to_i)) do |diaries|
            diaries.reverse_each do |date, entry|
              if entry.visible? and count < limit
                entries << entry
                count += 1
              end
              TDiaryBase::DIRTY_DIARY
            end
          end
          break if count >= limit
        end
        break if count >= limit
      end
      entries
    end
  end
end
