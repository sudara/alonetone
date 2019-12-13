# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'does not return a user' do
  it 'does not return a user' do
    expect(authenticated_session.user).to be_nil
  end

  it 'coerces to an empty hash' do
    expect(authenticated_session.to_hash).to be_empty
  end

  it 'does not match to the password from the credentials' do
    expect(authenticated_session.correct_password?).to eq(false)
  end

  it 'does not think it has an active user' do
    expect(authenticated_session.user_active?).to eq(false)
  end

  it 'does not save' do
    before = session.dup
    expect(authenticated_session.save).to eq(false)
    expect(session).to eq(before)
  end
end

RSpec.describe AuthenticatedSessionsController, type: :model do
  context 'request with an empty session' do
    let(:session) { {} }
    let(:authenticated_session) do
      AuthenticatedSession.new(session: session)
    end

    include_examples 'does not return a user'
  end

  context 'request authenticating with correct credentials' do
    let(:session) { {} }
    let(:user) { users(:will_studd) }
    let(:authenticated_session) do
      AuthenticatedSession.new(
        session: session, login: user.login, password: 'test'
      )
    end

    it 'returns the user' do
      expect(authenticated_session.user).to eq(user)
    end

    it 'coerces to a proper hash' do
      expect(authenticated_session.to_hash).to eq('user_id' => user.id)
    end

    it 'matches the password from the credentials' do
      expect(authenticated_session.correct_password?).to eq(true)
    end

    it 'has an active user' do
      expect(authenticated_session.user_active?).to eq(true)
    end

    it 'saves' do
      expect(authenticated_session.save).to eq(true)
      expect(session.keys).to eq(%w[authenticated_session])

      values = session['authenticated_session']
      expect(values.keys).to eq(%w[user_id])
      expect(values['user_id']).to eq(user.id)
    end
  end

  context 'request authenticating with correct credentials for inactive user' do
    let(:session) { {} }
    let(:user) { users(:not_activated) }
    let(:authenticated_session) do
      AuthenticatedSession.new(
        session: session, login: user.login, password: 'test'
      )
    end

    it 'returns the user' do
      expect(authenticated_session.user).to eq(user)
    end

    it 'coerces to a proper hash' do
      expect(authenticated_session.to_hash).to eq('user_id' => user.id)
    end

    it 'matches the password from the credentials' do
      expect(authenticated_session.correct_password?).to eq(true)
    end

    it 'does not have an active user' do
      expect(authenticated_session.user_active?).to eq(false)
    end

    it 'does not save' do
      expect(authenticated_session.save).to eq(false)
      expect(session).to be_empty
    end
  end

  context 'request authenticating with incorrect credentials' do
    let(:session) { {} }
    let(:user) { users(:will_studd) }
    let(:authenticated_session) do
      AuthenticatedSession.new(
        session: session, login: user.login, password: 'incorrect'
      )
    end

    it 'returns the user' do
      expect(authenticated_session.user).to eq(user)
    end

    it 'coerces to a proper hash' do
      expect(authenticated_session.to_hash).to eq('user_id' => user.id)
    end

    it 'does not match to the password from the credentials' do
      expect(authenticated_session.correct_password?).to eq(false)
    end

    it 'has an active user' do
      expect(authenticated_session.user_active?).to eq(true)
    end

    it 'does not save' do
      expect(authenticated_session.save).to eq(false)
      expect(session).to be_empty
    end
  end

  context 'request authenticating with unknown login' do
    let(:session) { {} }
    let(:user) { users(:will_studd) }
    let(:authenticated_session) do
      AuthenticatedSession.new(
        session: session, login: 'unknown', password: 'test'
      )
    end

    include_examples 'does not return a user'
  end

  context 'request authenticating with blank credentials' do
    let(:session) { {} }
    let(:user) { users(:will_studd) }
    let(:authenticated_session) do
      AuthenticatedSession.new(session: session, login: '', password: '')
    end

    include_examples 'does not return a user'
  end

  context 'request returning' do
    let(:session) { {} }
    let(:authenticated_session) { AuthenticatedSession.new(session: session) }

    before do
      AuthenticatedSession.new(
        session: session, login: user.login, password: 'test'
      ).save
    end

    context 'with valid session' do
      let(:user) { users(:will_studd) }

      it 'returns the user' do
        expect(authenticated_session.user).to eq(user)
      end

      it 'coerces to a proper hash' do
        expect(authenticated_session.to_hash).to eq('user_id' => user.id)
      end

      it 'does not match to the unset password' do
        expect(authenticated_session.correct_password?).to eq(false)
      end

      it 'has an active user' do
        expect(authenticated_session.user_active?).to eq(true)
      end

      it 'does not save' do
        before = session.dup
        expect(authenticated_session.save).to eq(false)
        expect(session).to eq(before)
      end

      it 'destroys' do
        expect(authenticated_session.destroy).to eq(true)
        expect(session).to be_empty
      end
    end

    context 'with a soft-deleted user' do
      let(:user) { users(:deleted_yesterday) }

      include_examples 'does not return a user'

      it 'does not destroy' do
        expect(authenticated_session.destroy).to eq(false)
      end
    end
  end

  context 'returning with a deleted user' do
    let(:session) { { 'authenticated_session' => { 'user_id' => 65535 } } }
    let(:authenticated_session) { AuthenticatedSession.new(session: session) }

    include_examples 'does not return a user'

    it 'destroys' do
      expect(authenticated_session.destroy).to eq(true)
      expect(session).to be_empty
    end
  end

  context 'returning with a broken session' do
    let(:session) { { 'authenticated_session' => {} } }
    let(:authenticated_session) { AuthenticatedSession.new(session: session) }

    include_examples 'does not return a user'

    it 'destroys' do
      expect(authenticated_session.destroy).to eq(true)
      expect(session).to be_empty
    end
  end
end
