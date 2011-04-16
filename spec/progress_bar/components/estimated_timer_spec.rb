require 'spec_helper'

describe ProgressBar::Components::EstimatedTimer do
  describe "#current=" do
    it "raises an error when passed a number larger than the total" do
      @estimated_time = ProgressBar::Components::EstimatedTimer.new(:total => 100)
      lambda{ @estimated_time.current = 101 }.should raise_error "You can't set the item's current value to be greater than the total."
    end
  end

  describe "#to_s" do
    context "when the timer has been started but no progress has been made" do
      before do
        @estimated_time = ProgressBar::Components::EstimatedTimer.new(:total => 100)
        @estimated_time.start
      end

      it "displays an unknown time remaining" do
        @estimated_time.to_s.should eql " ETA: ??:??:??"
      end

      context "and it is incremented" do
        it "should not display unknown time remaining" do
          @estimated_time.increment
          @estimated_time.to_s.should_not eql " ETA: ??:??:??"
        end
      end
    end

    context "when half the progress has been made" do
      context "and it took 3:42:12 to do it" do
        it "displays 3:42:12 remaining" do
          @estimated_time = ProgressBar::Components::EstimatedTimer.new(:beginning_position => 0, :total => 100)

          Timecop.travel(-13332) do
            @estimated_time.start
          end

          @estimated_time.current = 50
          @estimated_time.to_s.should eql " ETA: 03:42:12"
        end
      end
    end

    context "when it's estimated to take longer than 99:59:59" do
      before do
          @estimated_time = ProgressBar::Components::EstimatedTimer.new(:beginning_position => 0, :total => 100)

          Timecop.travel(-120000) do
            @estimated_time.start
            @estimated_time.current = 25
          end
      end

      context "and the out of bounds time format has been set to 'friendly'" do
        before { @estimated_time.out_of_bounds_time_format = :friendly }

        it "displays '> 4 Days' remaining" do
          @estimated_time.to_s.should eql " ETA: > 4 Days"
        end
      end

      context "and the out of bounds time format has been set to 'unknown'" do
        before { @estimated_time.out_of_bounds_time_format = :unknown }

        it "displays '??:??:??' remaining" do
          @estimated_time.to_s.should eql " ETA: ??:??:??"
        end
      end

      it "displays the correct time remaining" do
        @estimated_time.to_s.should eql " ETA: 100:00:00"
      end
    end
  end

  describe "#out_of_bounds_time_format=" do
    context "when set to an invalid format" do
      it "raises an exception" do
        @estimated_time = ProgressBar::Components::EstimatedTimer.new(:total => 100)
        lambda{ @estimated_time.out_of_bounds_time_format = :foo }.should raise_error("Invalid Out Of Bounds time format.  Valid formats are [:unknown, :friendly, nil]")
      end
    end
  end
end
