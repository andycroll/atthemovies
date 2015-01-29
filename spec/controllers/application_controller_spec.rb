require 'rails_helper'

describe ApplicationController do
  before { allow(controller).to receive(:controller_path) { 'movies' } }

  describe '#action_for_js' do
    subject { controller.action_for_js }

    context 'on #create' do
      before { allow(controller).to receive(:action_name) { 'create' } }
      it { is_expected.to eq('new') }
    end

    context 'on #edit' do
      before { allow(controller).to receive(:action_name) { 'edit' } }
      it { is_expected.to eq('edit') }
    end

    context 'on #index' do
      before { allow(controller).to receive(:action_name) { 'index' } }
      it { is_expected.to eq('index') }
    end

    context 'on #new' do
      before { allow(controller).to receive(:action_name) { 'new' } }
      it { is_expected.to eq('new') }
    end

    context 'on #show' do
      before { allow(controller).to receive(:action_name) { 'show' } }
      it { is_expected.to eq('show') }
    end

    context 'on #update' do
      before { allow(controller).to receive(:action_name) { 'update' } }
      it { is_expected.to eq('edit') }
    end
  end

  describe '#body_class' do
    subject { controller.body_class }

    context 'on #create' do
      before { allow(controller).to receive(:action_name) { 'create' } }
      it { is_expected.to eq('movies new') }
    end

    context 'on #edit' do
      before { allow(controller).to receive(:action_name) { 'edit' } }
      it { is_expected.to eq('movies edit') }
    end

    context 'on #index' do
      before { allow(controller).to receive(:action_name) { 'index' } }
      it { is_expected.to eq('movies index') }
    end

    context 'on #new' do
      before { allow(controller).to receive(:action_name) { 'new' } }
      it { is_expected.to eq('movies new') }
    end

    context 'on #show' do
      before { allow(controller).to receive(:action_name) { 'show' } }
      it { is_expected.to eq('movies show') }
    end

    context 'on #update' do
      before { allow(controller).to receive(:action_name) { 'update' } }
      it { is_expected.to eq('movies edit') }
    end

    context 'when @body_class is set' do
      before do
        allow(controller).to receive(:action_name) { 'show' }
        controller.instance_variable_set(:@body_class, 'boom')
      end

      it { is_expected.to eq('boom') }
    end
  end

  describe '#body_id' do
    subject { controller.body_id }

    context 'on #create' do
      before { allow(controller).to receive(:action_name) { 'create' } }
      it { is_expected.to eq('movies-new') }
    end

    context 'on #edit' do
      before { allow(controller).to receive(:action_name) { 'edit' } }
      it { is_expected.to eq('movies-edit') }
    end

    context 'on #index' do
      before { allow(controller).to receive(:action_name) { 'index' } }
      it { is_expected.to eq('movies-index') }
    end

    context 'on #new' do
      before { allow(controller).to receive(:action_name) { 'new' } }
      it { is_expected.to eq('movies-new') }
    end

    context 'on #show' do
      before { allow(controller).to receive(:action_name) { 'show' } }
      it { is_expected.to eq('movies-show') }
    end

    context 'on #update' do
      before { allow(controller).to receive(:action_name) { 'update' } }
      it { is_expected.to eq('movies-edit') }
    end

    context 'when @body_id is set' do
      before do
        allow(controller).to receive(:action_name) { 'show' }
        controller.instance_variable_set(:@body_id, 'boom')
      end

      it { is_expected.to eq('boom') }
    end
  end

  describe '#controller_for_js' do
    subject { controller.controller_for_js }

    context 'regular controller' do
      it { is_expected.to eq('movies') }
    end

    context 'namespaced controller' do
      before { allow(controller).to receive(:controller_path) { 'admin/movies' } }
      it { is_expected.to eq('admin.movies') }
    end
  end
end
