require 'rails_helper'

describe '[STEP1] ユーザログイン前のテスト' do
  describe 'トップ画面のテスト' do
    before do
      visit root_path


     context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/'
      end
      it 'Log inリンクが表示される' do
        expect(page).to have_button 'ログイン'
      end
      it 'Log inリンクの内容が正しい' do
        expect(page).to have_link 'ログイン', href: new_user_session_path
      end
      it 'Sign Upリンクが表示される' do
        expect(page).to have_button '新規登録'
      end
      it 'Sign Upリンクの内容が正しい' do
        expect(page).to have_link '新規登録', href: new_user_registration_path
      end
     end
    end
  end

  describe 'ヘッダーのテスト: ログインしていない場合' do
    before do
      visit root_path


     context '表示内容の確認' do
      it 'タイトルが表示される' do
        expect(page).to have_selector "img[src$='logo_png']"
      end
      it 'Log inリンクが表示される' do
        expect(page).to have_button 'ログイン'
      end
      it 'Log inリンクの内容が正しい' do
        expect(page).to have_link 'ログイン', href: new_user_session_path
      end
      it 'Sign Upリンクが表示される' do
        expect(page).to have_button '新規登録'
      end
      it 'Sign Upリンクの内容が正しい' do
        expect(page).to have_link '新規登録', href: new_user_registration_path
      end
     end

     context 'リンクの内容を確認' do
      subject { current_path }

      it 'ロゴを押すと、トップ画面に遷移する' do
        click_link 'logo_png'
      end
      it '新規登録を押すと、新規登録画面に遷移する' do
        click_link '新規登録'
        is_expected.to eq '/users/sign_up'
      end
      it 'ログインを押すと、ログイン画面に遷移する' do
        click_link 'ログイン'
        is_expected.to eq '/users/sign_in'
      end
     end
    end
  end

  describe 'ユーザ新規登録のテスト' do
    before do
      visit new_user_registration_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/users/sign_up'
      end
      it '「新規登録」と表示される' do
        expect(page).to have_content '新規登録'
      end
      it '「ユーザーネーム」フォームが表示される' do
        expect(page).to have_field 'user[name]'
      end
      it 'emailフォームが表示される' do
        expect(page).to have_field 'user[email]'
      end
      it 'passwordフォームが表示される' do
        expect(page).to have_field 'user[password]'
      end
      it 'password_confirmationフォームが表示される' do
        expect(page).to have_field 'user[password_confirmation]'
      end
      it '登録ボタンが表示される' do
        expect(page).to have_button '登録'
      end
    end

    context '新規登録成功のテスト' do
      before do
        fill_in 'user[name]', with: Faker::Lorem.characters(number: 10)
        fill_in 'user[email]', with: Faker::Internet.email
        fill_in 'user[password]', with: 'password'
        fill_in 'user[password_confirmation]', with: 'password'
      end

      it '正しく新規登録される' do
        expect { click_button '登録' }.to change(User.all, :count).by(1)
      end
      it '新規登録後のリダイレクト先が、Postのindex画面になっている' do
        click_button '登録'
        expect(current_path).to eq '/posts'
      end
    end
  end

  describe 'ユーザログイン' do
    let(:user) { create(:user) }

    before do
      visit new_user_session_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/users/sign_in'
      end
      it '「ログイン」と表示される' do
        expect(page).to have_content 'ログイン'
      end
      it '「ユーザーネーム」フォームが表示される' do
        expect(page).to have_field 'user[name]'
      end
      it 'emailフォームは表示される' do
        expect(page).to have_field 'user[email]'
      end
      it 'passwordフォームが表示される' do
        expect(page).to have_field 'user[password]'
      end
      it '「ログイン」ボタンが表示される' do
        expect(page).to have_button 'ログイン'
      end
    end

    context 'ログイン成功のテスト' do
      before do
        fill_in 'user[name]', with: user.name
        fill_in 'user[email]', with: user.email
        fill_in 'user[password]', with: user.password
        click_button 'ログイン'
      end

      it 'ログイン後のリダイレクト先が、Postのindex画面になっている' do
        expect(current_path).to eq '/posts'
      end
    end

    context 'ログイン失敗のテスト' do
      before do
        fill_in 'user[name]', with: ''
        fill_in 'user[email]', with: ''
        fill_in 'user[password]', with: ''
        click_button 'ログイン'
      end

      it 'ログインに失敗し、ログイン画面にリダイレクトされる' do
        expect(current_path).to eq '/users/sign_in'
      end
    end
  end

  describe 'ヘッダーのテスト: ログインしている場合' do
    let(:user) { create(:user) }

    before do
      visit new_user_session_path
      fill_in 'user[name]', with: user.name
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'ログイン'


     context 'ヘッダーの表示を確認' do
      it '「Top」リンクが表示される' do
        expect(page).to have_button 'Top'
      end
      it '「ユーザーリンク」が表示される' do
        expect(page).to have_button 'ユーザー'
      end
      it '「新規登録」リンクが表示される' do
        expect(page).to have_button '新規登録'
      end
      it '「マイページ」リンクが表示される' do
        expect(page).to have_button 'マイページ'
      end
      it '「About]リンクが表示される' do
        expect(page).to have_button 'About'
      end
      it '「ログアウト」リンクが表示される' do
        expect(page).to have_button 'ログアウト'
      end
     end
    end
  end

  describe 'ユーザログアウトのテスト' do
    let(:user) { create(:user) }

    before do
      visit new_user_session_path
      fill_in 'user[name]', with: user.name
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'ログイン'
      click_link 'ログアウト'

     context 'ログアウト機能のテスト' do
      it '正しくログアウトできている: ログアウト後のリダイレクト先が、トップになっている' do
        expect(page).to have_link '', href: '/'
      end
     end
   end
  end
end
