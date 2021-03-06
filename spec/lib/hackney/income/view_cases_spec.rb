require 'rails_helper'

describe Hackney::Income::ViewCases do
  subject { view_cases.execute(page_number: page_number, number_per_page: number_per_page) }

  let(:page_number) { Faker::Number.number(2).to_i }
  let(:number_per_page) { Faker::Number.number(2).to_i }
  let(:tenancy_api_gateway) { Hackney::Income::TenancyApiGatewayStub.new({}) }
  let(:stored_tenancies_gateway) { Hackney::Income::StoredTenancyGatewayStub.new({}) }

  let(:view_cases) do
    described_class.new(
      tenancy_api_gateway: tenancy_api_gateway,
      stored_tenancies_gateway: stored_tenancies_gateway
    )
  end

  context 'when the stored tenancies gateway responds with no tenancies' do
    it 'returns nothing' do
      expect(subject.cases).to eq([])
    end
  end

  it 'does not do further queries if the page number returned is 0' do
    expect(stored_tenancies_gateway)
      .to receive(:number_of_pages)
      .and_call_original

    expect(stored_tenancies_gateway).not_to receive(:get_tenancies)

    expect(subject.cases).to eq([])
    expect(subject.number_of_pages).to eq(0)
  end

  context 'when the stored tenancies gateway responds with a tenancy' do
    let(:tenancy_attributes) { random_tenancy_attributes }
    let(:other_tenancy_attributes) { random_tenancy_attributes }
    let(:tenancy_priority_factors) { random_tenancy_priority_factors }
    let(:tenancy_priority_band) { Faker::Internet.slug }
    let(:tenancy_priority_score) { Faker::Number.number(5).to_i }

    let(:tenancy_list) do
      {
        tenancy_attributes.fetch(:ref) => {
          tenancy_ref: tenancy_attributes.fetch(:ref),
          priority_band: tenancy_priority_band,
          priority_score: tenancy_priority_score
        }.merge(tenancy_priority_factors)
      }
    end

    let(:stored_tenancies_gateway) { Hackney::Income::StoredTenancyGatewayStub.new(tenancy_list) }

    it 'passes the correct page number and number per page into the stored tenancy gateway' do
      expect(stored_tenancies_gateway)
        .to receive(:get_tenancies)
        .with(a_hash_including(page_number: page_number, number_per_page: number_per_page))
        .and_call_original

      subject
    end

    context 'without tenancy details being found' do
      it 'ignores the tenancy' do
        expect(subject.cases).to eq([])
      end
    end

    context 'when full tenancy details are be found' do
      let(:tenancy_api_gateway) do
        Hackney::Income::TenancyApiGatewayStub.new(
          other_tenancy_attributes.fetch(:ref) => other_tenancy_attributes,
          tenancy_attributes.fetch(:ref) => tenancy_attributes
        )
      end

      it 'returns full details for the correct tenancy' do
        expect(subject.cases.count).to eq(1)
        expect(subject.cases).to include(a_hash_including(
                                           ref: tenancy_attributes.fetch(:ref),
                                           current_balance: tenancy_attributes.fetch(:current_balance),
                                           current_arrears_agreement_status: tenancy_attributes.fetch(:current_arrears_agreement_status),

                                           latest_action: {
                                             code: tenancy_attributes.dig(:latest_action, :code),
                                             date: tenancy_attributes.dig(:latest_action, :date)
                                           },

                                           primary_contact: {
                                             name: tenancy_attributes.dig(:primary_contact, :name),
                                             short_address: tenancy_attributes.dig(:primary_contact, :short_address),
                                             postcode: tenancy_attributes.dig(:primary_contact, :postcode)
                                           },

                                           balance: tenancy_priority_factors.fetch(:balance),
                                           days_in_arrears: tenancy_priority_factors.fetch(:days_in_arrears),
                                           days_since_last_payment: tenancy_priority_factors.fetch(:days_since_last_payment),
                                           number_of_broken_agreements: tenancy_priority_factors.fetch(:number_of_broken_agreements),
                                           active_agreement: tenancy_priority_factors.fetch(:active_agreement),
                                           broken_court_order: tenancy_priority_factors.fetch(:broken_court_order),
                                           nosp_served: tenancy_priority_factors.fetch(:nosp_served),
                                           active_nosp: tenancy_priority_factors.fetch(:active_nosp),

                                           courtdate: tenancy_priority_factors.fetch(:courtdate),
                                           court_outcome: tenancy_priority_factors.fetch(:court_outcome),
                                           eviction_date: tenancy_priority_factors.fetch(:eviction_date),

                                           classification: tenancy_priority_factors.fetch(:classification),
                                           patch_code: tenancy_priority_factors.fetch(:patch_code),

                                           latest_active_agreement_date: tenancy_priority_factors.fetch(:latest_active_agreement_date),
                                           breach_agreement_date: tenancy_priority_factors.fetch(:latest_active_agreement_date),
                                           expected_balance: tenancy_priority_factors.fetch(:expected_balance),
                                           pause: {
                                             reason: tenancy_priority_factors.fetch(:pause_reason),
                                             comment: tenancy_priority_factors.fetch(:pause_comment),
                                             until: tenancy_priority_factors.fetch(:is_paused_until)
                                           }
                                         ))
      end

      context 'when filtering out paused cases' do
        subject {
          view_cases.execute(
            page_number: page_number,
            number_per_page: number_per_page,
            filters: {
              is_paused: true
            }
          )
        }

        it 'returns only paused cases' do
          expect(stored_tenancies_gateway)
            .to receive(:get_tenancies)
            .with(a_hash_including(
                    page_number: page_number,
                    number_per_page: number_per_page,
                    filters: {
                      is_paused: true
                    }
                  ))
            .and_call_original

          expect(stored_tenancies_gateway)
            .to receive(:number_of_pages)
            .with(a_hash_including(
                    number_per_page: number_per_page,
                    filters: {
                      is_paused: true
                    }
                  ))
            .and_call_original

          expect(subject.cases.count).to eq(1)
        end

        context 'when filtering paused cases by pause reason' do
          subject {
            view_cases.execute(
              page_number: page_number,
              number_per_page: number_per_page,
              filters: {
                is_paused: true,
                pause_reason: pause_reason
              }
            )
          }

          let(:pause_reason) { Faker::Lorem.word }

          it 'returns only paused cases filtered by pause reason' do
            expect(stored_tenancies_gateway)
              .to receive(:get_tenancies)
              .with(a_hash_including(
                      page_number: page_number,
                      number_per_page: number_per_page,
                      filters: {
                        is_paused: true,
                        pause_reason: pause_reason
                      }
                    ))
              .and_call_original

            expect(stored_tenancies_gateway)
              .to receive(:number_of_pages)
              .with(a_hash_including(
                      number_per_page: number_per_page,
                      filters: {
                        is_paused: true,
                        pause_reason: pause_reason
                      }
                    ))
              .and_call_original

            expect(subject.cases.count).to eq(1)
          end
        end
      end

      context 'when filtering cases by patch' do
        subject {
          view_cases.execute(
            page_number: page_number,
            number_per_page: number_per_page,
            filters: {
              patch: patch
            }
          )
        }

        let(:patch) { Faker::Lorem.characters(3) }

        it 'asks the gateway for cases filtered by patch' do
          expect(stored_tenancies_gateway)
            .to receive(:get_tenancies)
            .with(a_hash_including(
                    page_number: page_number,
                    number_per_page: number_per_page,
                    filters: {
                      patch: patch
                    }
                  )).and_call_original

          expect(stored_tenancies_gateway)
            .to receive(:number_of_pages)
            .with(a_hash_including(
                    number_per_page: number_per_page,
                    filters: {
                      patch: patch
                    }
                  )).and_call_original

          expect(subject.cases.count).to eq(1)
        end
      end
    end
  end

  context 'when counting the number of pages of tenancies' do
    let(:number_of_pages) { Faker::Number.number(3).to_i }

    it 'consults the stored tenancies gateway' do
      expect(stored_tenancies_gateway).to receive(:number_of_pages).with(
        number_per_page: number_per_page,
        filters: {}
      ).and_call_original
      subject
    end

    it 'returns what the stored tenancies gateway does' do
      allow(stored_tenancies_gateway).to receive(:number_of_pages).and_return(number_of_pages)
      expect(subject.number_of_pages).to eq(number_of_pages)
    end
  end

  it 'is serialisable as valid JSON' do
    loaded_json = JSON.parse(subject.to_json)

    expect(loaded_json.fetch('cases')).to be_a(Array)
    expect(loaded_json.fetch('number_of_pages')).to be_an(Integer)
  end

  def random_tenancy_priority_factors
    {
      balance: Faker::Commerce.price,
      days_in_arrears: Faker::Number.number(2),
      days_since_last_payment: Faker::Number.number(2),
      number_of_broken_agreements: Faker::Number.number(1),
      active_agreement: Faker::Number.between(0, 1),
      broken_court_order: Faker::Number.between(0, 1),
      nosp_served: Faker::Number.between(0, 1),
      active_nosp: Faker::Number.between(0, 1),

      courtdate: Date.today - 5,
      court_outcome: Faker::Lorem.word,
      eviction_date: Date.today + 1.month,
      patch_code: Faker::Lorem.characters(3),
      classification: 'no_action',
      latest_active_agreement_date: 1.week.ago,
      breach_agreement_date: 5.days.ago,
      expected_balance: Faker::Commerce.price,
      pause_reason: Faker::Lorem.characters(3),
      pause_comment: Faker::Lorem.characters(3),
      is_paused_until: Date.today + 1.day
    }
  end

  def random_tenancy_attributes(tenancy_ref = nil)
    {
      ref: tenancy_ref || Faker::Internet.slug,
      current_balance: Faker::Commerce.price,
      current_arrears_agreement_status: Faker::Internet.slug,
      latest_action: {
        code: Faker::Internet.slug,
        date: Faker::Time.forward(23, :morning)
      },
      primary_contact: {
        name: Faker::TheFreshPrinceOfBelAir.character,
        short_address: Faker::Address.street_address,
        postcode: Faker::Address.postcode
      }
    }
  end
end
