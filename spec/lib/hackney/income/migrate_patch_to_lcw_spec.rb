describe Hackney::Income::MigratePatchToLcw do
  subject { described_class.new(legal_cases_gateway: legal_cases_gateway, user_assignment_gateway: user_assignment_gateway) }
  let(:legal_cases_gateway) { double('Universal Housing Gateway') }
  let(:user_assignment_gateway) { double('Tenancies Gateway') }

  let(:patch_code) { Faker::Lorem.characters(3) }
  let(:user_id) { Faker::Number.number(2) }
  let(:tenancy_ref_array) { [Faker::Lorem.characters(8), Faker::Lorem.characters(8)] }

  context 'given a user id and a patch, assigns all legal cases to that user' do
    it 'should pass the patch to the SQL legal cases gateway' do
      expect(legal_cases_gateway).to receive(:get_tenancies_for_legal_process_for_patch).with(
        patch: patch_code
      ).and_return(tenancy_ref_array)

      expect(user_assignment_gateway).to receive(:assign_user).with(
        tenancy_ref: tenancy_ref_array[0],
        user_id: user_id
      )

      expect(user_assignment_gateway).to receive(:assign_user).with(
        tenancy_ref: tenancy_ref_array[1],
        user_id: user_id
      )

      subject.execute(patch: patch_code, user_id: user_id)
    end
  end
end
