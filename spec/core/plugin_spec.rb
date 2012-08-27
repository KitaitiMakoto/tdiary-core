# -*- coding: utf-8 -*-
require 'spec_helper'

require File.dirname(__FILE__) + "/../plugin/plugin_helper"
require 'tdiary/plugin'

describe TDiary::Plugin do
	before do
		config = PluginFake::Config.new
		config.plugin_path = 'spec/fixtures/plugin'
		@plugin = TDiary::Plugin.new({ :conf => config, :debug => true })
	end

	describe '#load_plugin' do
		before { @plugin.load_plugin('spec/fixtures/plugin/sample.rb') }
		subject { @plugin }

		it '読み込まれたプラグインのメソッドを呼び出せること' do
			subject.sample.should eq 'sample plugin'
		end

		it 'プラグイン一覧が @plugin_files で取得できること' do
			subject.instance_variable_get(:@plugin_files).should include('spec/fixtures/plugin/sample.rb')
		end

		context 'リソースファイルが存在する場合' do
			before { pending 'To be written' }

			it 'Confファイルで指定した言語に対応するリソースが読み込まれること'
		end
	end

	describe '#eval_src' do
		before { @src = ERB::new('hello <%= sample %><%= undefined_method %>').src }
		subject { @plugin.eval_src(@src, false) }

		context 'debugモードがOFFの場合' do
			before { @plugin.instance_variable_set(:@debug, false) }

			it 'Pluginオブジェクト内でソースが実行されること' do
				subject.should eq 'hello sample plugin'
			end

			context 'secureモード指定の場合' do
				it 'Safeモード4で実行されること'
			end
		end

		context 'debugモードがONの場合' do
			before { @plugin.instance_variable_set(:@debug, true) }

			it 'Plugin内のエラーが通知されること' do
				expect { subject }.to raise_error
			end
		end
	end

	describe '#header_proc' do
		before do
			@plugin.__send__(:add_header_proc, lambda { 'header1 ' })
			@plugin.__send__(:add_header_proc, lambda { 'header2' })
		end
		subject { @plugin.__send__(:header_proc) }

		it 'add_header_procで登録したブロックが実行されること' do
			should eq 'header1 header2'
		end
	end

	describe '#footer_proc' do
		before do
			@plugin.__send__(:add_footer_proc, lambda { 'footer1 ' })
			@plugin.__send__(:add_footer_proc, lambda { 'footer2' })
		end
		subject { @plugin.__send__(:footer_proc) }

		it 'add_footer_procで登録したブロックが実行されること' do
			should eq 'footer1 footer2'
		end
	end

	describe '#update_proc' do
		let (:proc1) { lambda {} }
		let (:proc2) { lambda {} }
		before do
			@plugin.__send__(:add_update_proc, proc1)
			@plugin.__send__(:add_update_proc, proc2)
		end
		subject { @plugin.__send__(:update_proc, nil, nil) }

		it 'add_update_procで登録したブロックが実行されること' do
			proc1.should_receive(:call)
			proc2.should_receive(:call)
			# should_receiveの場合はsubjectが使えないため明示的に実行
			@plugin.__send__(:update_proc)
		end

		it '空の文字列を返すこと' do
			should eq ''
		end
	end

	describe '#title_proc' do
		let (:proc1) { lambda {|date, title| "#{title}:title1" } }
		let (:proc2) { lambda {|date, title| "#{title}:title2" } }
		before do
			@plugin.__send__(:add_title_proc, proc1)
			@plugin.__send__(:add_title_proc, proc2)
		end
		subject { @plugin.__send__(:title_proc, nil, nil) }

		it 'add_title_procで登録したブロックを実行し、タイトル文字列を返すこと' do
			should eq ':title1:title2'
		end

		it 'apply_pluginメソッドを呼び出すこと' do
			@plugin.should_receive(:apply_plugin)
			# should_receiveの場合はsubjectが使えないため明示的に実行
			@plugin.__send__(:title_proc, nil, nil)
		end
	end

	describe '#body_enter_proc' do
		it 'add_body_enter_procで登録したブロックが実行されること'
	end

	describe '#body_leave_proc' do
		it 'add_body_leave_procで登録したブロックが実行されること'
	end

	describe '#section_enter_proc' do
		it 'add_section_enter_procで登録したブロックが実行されること'
	end

	describe '#subtitle_proc' do
		it 'add_subtitle_procで登録したブロックが実行されること'
	end

	describe '#section_leave_proc' do
		it 'add_section_leave_procで登録したブロックが実行されること'
	end

	describe '#comment_leave_proc' do
		it 'add_comment_leave_procで登録したブロックが実行されること'
	end

	describe '#edit_proc' do
		it 'add_edit_procで登録したブロックが実行されること'
	end

	describe '#form_proc' do
		it 'add_form_procで登録したブロックが実行されること'
	end

	describe '#conf_proc' do
		it 'add_conf_procで登録したブロックが実行されること'
	end

	describe '#remove_tag' do
		before { @string = 'test <a href="http://example.com/">example.<b>com</b></a>' }
		subject { @plugin.__send__(:remove_tag, @string) }

		it '文字列からタグが除去されること' do
			should eq 'test example.com'
		end
	end

	describe '#apply_plugin' do
		it 'プラグインが再実行されること'

		context 'remove_tagがtrueの場合' do
			it 'remove_tagメソッドが呼び出されること'
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
