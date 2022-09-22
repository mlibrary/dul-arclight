# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Collection Warning Banner', type: :feature do
  before { visit solr_document_path(id: doc_id) }

  describe 'a collection with a banner-denoted accessrestrict' do
    context 'when on the collection page' do
      let(:doc_id) { 'whitewendel' }

      it 'renders the warning banner' do
        expect(page).to have_css('#collection-alert')
        expect(page).to have_css('span', text: 'Please Note')
      end
    end
    context 'when on a component page' do
      let(:doc_id) { 'whitewendel_aspace_df7fb947d4113931ddf4d9d0e4b2bb01' }

      it 'renders the warning banner' do
        expect(page).to have_css('#collection-alert')
        expect(page).to have_css('span', text: 'Please Note')
      end
    end
  end
end
