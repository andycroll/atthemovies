# frozen_string_literal: true
class Api::V1::CinemasController < ApplicationController
  def index
    @cinemas = Cinema.all
    render json: @cinemas
  end
end
