require 'rails_helper'

describe Hackney::Income::UniversalHousingTenanciesGateway, universal: true do
  let(:gateway) { described_class.new }

  after { truncate_uh_tables }

  context 'retrieving tenancy refs for cases in arrears' do
    subject { gateway.tenancies_in_arrears }

    context 'when there are no tenancies' do
      it 'should return none' do
        expect(subject).to be_empty
      end
    end

    context 'when there is one tenancy in arrears' do
      before { create_uh_tenancy_agreement(tenancy_ref: '000001/01', current_balance: 50.00) }

      it 'should return that tenancy' do
        expect(subject).to eq(['000001/01'])
      end
    end

    context 'when there is one tenancy in credit' do
      before { create_uh_tenancy_agreement(tenancy_ref: '000001/01', current_balance: -50.00) }

      it 'should return nothing' do
        expect(subject).to eq([])
      end
    end

    context 'when there are two tenancies in arrears and two in credit' do
      before do
        create_uh_tenancy_agreement(tenancy_ref: '000001/01', current_balance: -100.00)
        create_uh_tenancy_agreement(tenancy_ref: '000002/01', current_balance: 50.00)
        create_uh_tenancy_agreement(tenancy_ref: '000003/01', current_balance: -75.00)
        create_uh_tenancy_agreement(tenancy_ref: '000004/01', current_balance: 100.00)
      end

      it 'should return the two in arrears' do
        expect(subject).to eq(['000002/01', '000004/01'])
      end
    end

    context 'when patches are restricted' do
      context 'and a list of acceptable patches is given' do
        let(:gateway) { described_class.new(restrict_patches: true, patches: ['X01', 'Y01', 'Z01']) }

        context 'and a tenancy is not in an accepted patch' do
          before do
            create_uh_tenancy_agreement(tenancy_ref: '00001/01', current_balance: 10.0, property_ref: 'PROP1')
            create_uh_property(property_ref: 'PROP1', patch_code: 'B01')
          end

          it 'should not return the tenancy' do
            expect(subject).to be_empty
          end
        end

        context 'and a tenancy is in one of the accepted patches' do
          before do
            create_uh_tenancy_agreement(tenancy_ref: '00001/01', current_balance: 10.0, property_ref: 'PROP1')
            create_uh_property(property_ref: 'PROP1', patch_code: 'Z01')
          end

          it 'should include the tenancy' do
            expect(subject).to eq(['00001/01'])
          end
        end
      end

      context 'when no list of acceptable patches is given' do
        let(:gateway) { described_class.new(restrict_patches: true) }

        before do
          create_uh_tenancy_agreement(tenancy_ref: '00001/01', current_balance: 10.0, property_ref: 'PROP1')
          create_uh_property(property_ref: 'PROP1', patch_code: 'B01')
        end

        it 'should return no tenancies' do
          expect(subject).to eq([])
        end
      end
    end
  end
end
