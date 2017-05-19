describe Composition::Macros::Compose do

  describe 'compose getter' do
    context 'when there is at least 1 value in the composed object' do
      let(:user) { User.new(credit_card_name: 'Jon Snow', credit_card_brand: 'Visa') }

      before do
        create_table(:users) do |t|
          t.string :credit_card_name
          t.string :credit_card_brand
        end

        spawn_model(:User) do
          compose :credit_card,
                  mapping: {
                    credit_card_name: :name,
                    credit_card_brand: :brand
                  }
        end

        spawn_composition(:CreditCard) do
          composed_from :user
        end
      end

      it { expect(user.credit_card).to be_an_instance_of(CreditCard) }
      it { expect(user.credit_card.name).to eq 'Jon Snow' }
      it { expect(user.credit_card.brand).to eq 'Visa' }
      it { expect(user.credit_card.user).to eq user }
    end

    context 'when every attribute is nil' do
      let(:user) { User.new(credit_card_name: nil, credit_card_brand: nil) }

      before do
        create_table(:users) do |t|
          t.string :credit_card_name
          t.string :credit_card_brand
        end

        spawn_model(:User) do
          compose :credit_card,
                  mapping: {
                    credit_card_name: :name,
                    credit_card_brand: :brand
                  }
        end

        spawn_composition(:CreditCard) do
          composed_from :user
        end
      end

      it { expect(user.credit_card).to be_nil }
    end

    context 'when using class_name' do
      let(:user) { AdminUser.new(credit_card_name: 'Jon Snow', credit_card_brand: 'Visa') }

      before do
        create_table(:admin_users) do |t|
          t.string :credit_card_name
          t.string :credit_card_brand
        end

        spawn_model(:AdminUser) do
          compose :credit_card,
                  mapping: {
                    credit_card_name: :name,
                    credit_card_brand: :brand
                  }, class_name: 'CCard'
        end

        spawn_composition(:CCard) do
          composed_from :user, class_name: 'AdminUser'
        end
      end

      it { expect(user.credit_card).to be_an_instance_of(CCard) }
      it { expect(user.credit_card.name).to eq 'Jon Snow' }
      it { expect(user.credit_card.brand).to eq 'Visa' }
      it { expect(user.credit_card.user).to eq user }
    end
  end

  describe 'compose setter' do
    let(:user) { User.new(credit_card_name: 'Jon Snow', credit_card_brand: 'Visa') }

    before do
      create_table(:users) do |t|
        t.string :credit_card_name
        t.string :credit_card_brand
      end

      spawn_model(:User) do
        compose :credit_card,
                mapping: {
                  credit_card_name: :name,
                  credit_card_brand: :brand
                }
      end

      spawn_composition(:CreditCard) do
        composed_from :user
      end
    end

    context 'when setting attributes separately' do
      before do
        user.credit_card.name = 'Arya Stark'
        user.credit_card.brand = 'MasterCard'
      end

      it { expect(user.credit_card.name).to eq 'Arya Stark' }
      it { expect(user.credit_card_name).to eq 'Arya Stark' }
      it { expect(user.credit_card.brand).to eq 'MasterCard' }
      it { expect(user.credit_card_brand).to eq 'MasterCard' }

      context 'and saving' do
        before { user.save! && user.reload }
        it { expect(user.credit_card.name).to eq 'Arya Stark' }
        it { expect(user.credit_card_name).to eq 'Arya Stark' }
        it { expect(user.credit_card.brand).to eq 'MasterCard' }
        it { expect(user.credit_card_brand).to eq 'MasterCard' }
      end
    end

    context 'when setting attributes through assign_attributes' do
      before do
        user.update_attributes(credit_card: { name: 'Arya Stark', brand: 'MasterCard' })
      end

      it { expect(user.credit_card.name).to eq 'Arya Stark' }
      it { expect(user.credit_card_name).to eq 'Arya Stark' }
      it { expect(user.credit_card.brand).to eq 'MasterCard' }
      it { expect(user.credit_card_brand).to eq 'MasterCard' }
    end

    context 'when setting attributes (partially) through assign_attributes' do
      before do
        user.update_attributes(credit_card: { brand: 'MasterCard' })
      end

      it { expect(user.credit_card.name).to eq 'Jon Snow' }
      it { expect(user.credit_card_name).to eq 'Jon Snow' }
      it { expect(user.credit_card.brand).to eq 'MasterCard' }
      it { expect(user.credit_card_brand).to eq 'MasterCard' }
    end

    context 'when setting attributes using a new object' do
      before do
        user.credit_card = CreditCard.new(name: 'Arya Stark', brand: 'MasterCard')
      end

      it { expect(user.credit_card.name).to eq 'Arya Stark' }
      it { expect(user.credit_card_name).to eq 'Arya Stark' }
      it { expect(user.credit_card.brand).to eq 'MasterCard' }
      it { expect(user.credit_card_brand).to eq 'MasterCard' }
    end

    context 'when setting attribute through the base class' do
      before do
        user.credit_card_name = 'Arya Stark'
        user.credit_card_brand = 'MasterCard'
      end

      it { expect(user.credit_card.name).to eq 'Arya Stark' }
      it { expect(user.credit_card_name).to eq 'Arya Stark' }
      it { expect(user.credit_card.brand).to eq 'MasterCard' }
      it { expect(user.credit_card_brand).to eq 'MasterCard' }
    end

    context 'when setting to nil using =' do
      before { user.credit_card = nil }

      it { expect(user.credit_card).to be_nil }
      it { expect(user.credit_card_name).to be_nil }
      it { expect(user.credit_card_brand).to be_nil }
    end

    context 'when setting to nil using {}' do
      before { user.update_attributes(credit_card: nil) }

      it { expect(user.credit_card).to be_nil }
      it { expect(user.credit_card_name).to be_nil }
      it { expect(user.credit_card_brand).to be_nil }
    end
  end

  describe 'validations' do
    let(:user) { User.new(credit_card_name: 'Jon Snow', credit_card_brand: 'Visa') }

    before do
      create_table(:users) do |t|
        t.string :credit_card_name
        t.string :credit_card_brand
      end

      spawn_model(:User) do
        compose :credit_card,
                mapping: {
                  credit_card_name: :name,
                  credit_card_brand: :brand
                }
      end

      spawn_composition(:CreditCard) do
        composed_from :user

        validates :name, presence: true
      end
    end

    context 'when credit_card is valid' do
      it { expect(user.credit_card).to be_valid }
    end

    context 'when credit_card is not valid' do
      before { user.credit_card.name = '' }

      it { expect(user.credit_card).not_to be_valid }
    end
  end

  describe '#attributes' do
    let(:user) { User.new(credit_card_name: 'Jon Snow', credit_card_brand: 'Visa') }

    before do
      create_table(:users) do |t|
        t.string :credit_card_name
        t.string :credit_card_brand
      end

      spawn_model(:User) do
        compose :credit_card,
                mapping: {
                  credit_card_name: :name,
                  credit_card_brand: :brand
                }
      end

      spawn_composition(:CreditCard) do
        composed_from :user

        validates :name, presence: true
      end
    end

    it { expect(user.credit_card.attributes).to eq(name: 'Jon Snow', brand: 'Visa') }
  end
end
