# frozen_string_literal: true

class FlashComponent < ViewComponent::Base
  FLASH_CLASS = {
    notice: {
      class: "bg-green-100 text-green-800 p-4 rounded-lg mb-4"
    },
    alert: {
      class: "bg-red-100 text-red-800 p-4 rounded-lg mb-4"
    }
  }.freeze

  attr_reader :flash, :type

  def initialize(flash:)
    @flash = flash
    @type = @flash.keys.first
  end

  def flash_msg
    flash[type]
  end

  def flash_class
    @flash_class ||= FLASH_CLASS.dig(type&.to_sym, :class)
  end

  private

  def render?
    @flash.any?
  end
end
