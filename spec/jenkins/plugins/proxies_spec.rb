require 'spec_helper'

describe Jenkins::Plugins::Proxies do
  Proxies = Jenkins::Plugins::Proxies
  before  do
    Proxies.clear
    @plugin = mock(Jenkins::Plugin)
    @proxies = Jenkins::Plugins::Proxies.new(@plugin)
  end

  describe "exporting a native ruby object" do

    before do
      @class = Class.new
      @object = @class.new
    end

    describe "when no wrapper exists for it" do

      describe "and there is a matching proxy class registered" do
        before do
          @proxy_class = Class.new
          @proxy_class.class_eval do
            attr_reader :plugin, :object
            def initialize(plugin, object)
              @plugin, @object = plugin, object
            end
          end
          Jenkins::Plugins::Proxies.register @class, @proxy_class
          @export = @proxies.export(@object)
        end

        it "instantiates the proxy" do
          @export.should be_kind_of(@proxy_class)
        end

        it "passes in the plugin and the wrapped object" do
          @export.plugin.should be(@plugin)
          @export.object.should be(@object)
        end
      end

      describe "and there is not an appropriate proxy class registered for it" do
        it "raises an exception on import" do
          expect {@proxies.export(@object)}.should raise_error
        end
      end
    end

    describe "when a wrapper has already existed" do
      before do
        @proxy = Object.new
        @proxies.link @object, @proxy
      end

      it "finds the same proxy on export" do
        @proxies.export(@object).should be(@proxy)
      end

      it "finds associated Ruby object on import" do
        @proxies.import(@proxy).should be(@object)
      end
    end

    describe "proxy matching" do
      describe "when there are two related classes" do
        before do
          @A = Class.new
          @B = Class.new(@A)
        end

        describe "and there is a proxy registered for the subclass but not the superclass" do
          before do
            @p = proxy_class
            Proxies.register @B, @p
          end

          it "will create a proxy for the subclass" do
            @proxies.export(@B.new).should be_kind_of(@p)
          end

          it "will fail to create a proxy for the superclass" do
            expect {@proxies.export @A.new}.should raise_error
          end
        end

        describe "and there is a proxy registered for the superclass but not the superclass" do
          before do
            @p = proxy_class
            Proxies.register @A, @p
          end
          it "will create a proxy for the superclass" do
            @proxies.export(@A.new).should be_kind_of(@p)
          end

          it "will create a proxy for the subclass" do
            @proxies.export(@B.new).should be_kind_of(@p)
          end
        end

        describe "and there is proxy registered for both classes" do

          before do
            @pA = proxy_class
            @pB = proxy_class
            Proxies.register @A, @pA
            Proxies.register @B, @pB
          end
          it "will create a proxy for the subclass with its registered proxy class" do
            @proxies.export(@A.new).should be_kind_of(@pA)
          end

          it "will create a proxy for the superclass with its registered proxy class" do
            @proxies.export(@B.new).should be_kind_of(@pB)
          end
        end
      end
    end

  end

  private

  def proxy_class
    cls = Class.new
    cls.class_eval do
      attr_reader :plugin, :object
      def initialize(plugin, object)
        @plugin, @object = plugin, object
      end
    end
    return cls
  end
end
