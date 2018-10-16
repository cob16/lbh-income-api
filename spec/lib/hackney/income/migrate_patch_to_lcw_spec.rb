describe Hackney::Income::MigratePatchToLcw do
  subject { described_class.new(gateway: legal_cases_gateway) }
  let(:legal_cases_gateway) { double('Universal Housing Gateway') }
  let(:tenancy_persistance_gateway) { double('Tenancies Gateway') }

  context 'given a user id and a patch, assigns all legal cases to that user' do
    it 'should pass the patch to the SQL legal cases gateway' do
      expect(legal_cases_gateway).to receive(:get_tenancies_for_legal_process_for_patch).with(
        patch: '12345'
      ).and_return(['12345', '56789'])

      expect(tenancy_persistance_gateway).to receive(:assign_user).with(
        tenancy_ref: '12345',
        user_id: 1
      )

      expect(tenancy_persistance_gateway).to receive(:assign_user).with(
        tenancy_ref: '56789',
        user_id: 1
      )

      subject.execute(patch: '12345', user_id: 1)
    end
  end
end
