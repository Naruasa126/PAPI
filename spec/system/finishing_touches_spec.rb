require 'rails_helper'

describe '[STEP3] 仕上げのテスト' do
  let(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:post) { create(:post, user: user) }
  let!(:other_post) { create(:post, user: other_user) }


  describe '処理失敗時のテスト' do
    context 'ユーザ新規登録失敗: nameを1文字にする' do
      before do
        visit new_user_registration_path
        @name = Faker::Lorem.characters(number: 1)
        @email = 'a' + user.email
        fill_in 'user[name]', with: @name
        fill_in 'user[email]', with: @email
        fill_in 'user[password]', with: 'password'
        fill_in 'user[password_confirmation]', with: 'password'
      end

      it '新規登録されない' do
        expect { click_button '登録' }.not_to change(User.all, :count)
      end
      it '新規登録画面を表示しており、フォームの内容が正しい' do
        click_button '登録'
        expect(page).to have_content '登録'
        expect(page).to have_field 'user[name]', with: @name
        expect(page).to have_field 'user[email]', with: @email
      end
      it 'バリデーションエラーが表示される' do
        click_button '登録'
        expect(page).to have_content "is too short (minimum is 2 characters)"
      end
    end

    context '投稿データの新規投稿失敗: 投稿一覧画面から行い、contentsを空にする' do
      before do
        visit new_user_session_path
        fill_in 'user[name]', with: user.name
        fill_in 'user[email]', with: user.email
        fill_in 'user[password]', with: user.password
        click_button 'ログイン'
        visit new_post_path
        @post = Faker::Lorem.characters(number: 19)
        fill_in 'post[contents]', with: @post

       it '投稿が保存されない' do
        expect { click_button '投稿する' }.not_to change(post.all, :count)
       end
       it '新規投稿画面を表示している' do
        click_button '投稿する'
        expect(current_path).to eq '/posts/new'
        expect(page).to have_content post.image
        expect(page).to have_content other_post.image
       end
       it '新規投稿フォームの内容が正しい' do
        expect(page).to have_field 'post[image]', with: @post
        expect(page).to have_field 'post[contents]', with: @post
        expect(find_field('post[contents]').text).to be_blank
        expect(page).to have_field 'post[address]', with: @post
       end
       it 'バリデーションエラーが表示される' do
        click_button '投稿する'
        expect(page).to have_content "can't be blank"
       end
      end
    end

    context '投稿データの更新失敗: contentsを空にする' do
      before do
        visit new_user_session_path
        fill_in 'user[name]', with: user.name
        fill_in 'user[email]', with: user.email
        fill_in 'user[password]', with: user.password
        click_button 'ログイン'
        visit edit_post_path(post)
        @post_old_contents = post.contents
        fill_in 'post[contents]', with: ''
        click_button '変更する'


       it '投稿が更新されない' do
        expect(post.reload.contents).to eq @post_old_contents
       end
       it '投稿編集画面を表示しており、フォームの内容が正しい' do
        expect(current_path).to eq '/posts/' + post.id.to_s + '/edit'
        expect(find_field('post[contents]').text).to be_blank
        expect(page).to have_field 'post[contents]', with: @post
       end
       it 'エラーメッセージが表示される' do
        expect(page).to have_content 'error'
       end
      end
    end
  end

  describe 'ログインしていない場合のアクセス制限のテスト: アクセスできず、ログイン画面に遷移する' do
    subject { current_path }

    it 'ユーザ一覧画面' do
      visit users_path
      is_expected.to eq '/users/sign_in'
    end
    it 'ユーザ詳細画面' do
      visit user_path(user)
      is_expected.to eq '/users/sign_in'
    end
    it 'ユーザ情報編集画面' do
      visit edit_user_path(user)
      is_expected.to eq '/users/sign_in'
    end
    it '投稿一覧画面' do
      visit posts_path
      is_expected.to eq '/users/sign_in'
    end
    it '新規投稿画面' do
      visit new_post_path
      is_expected.to eq '/users/sign_in'
    end
    it '投稿詳細画面' do
      visit post_path(post)
      is_expected.to eq '/users/sign_in'
    end
    it '投稿編集画面' do
      visit edit_post_path(post)
      is_expected.to eq '/users/sign_in'
    end
  end

  describe '他人の画面のテスト' do
    before do
      visit new_user_session_path
      fill_in 'user[name]', with: user.name
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'ログイン'
    end

    describe '他人の投稿詳細画面のテスト' do
      before do
        visit post_path(other_post)

     　 context '表示内容の確認' do
        it 'URLが正しい' do
          expect(current_path).to eq '/posts/' + other_post.id.to_s
        end
        it 'ユーザ名前が表示される' do
          expect(page).to have_content post.user.name
        end
        it '投稿の画像が表示される' do
          expect(page).to have_selector("img[src$='no_image.jpg']")
        end
        it '投稿のcontentsが表示される' do
          expect(page).to have_content post.contents
        end
        it '投稿の編集リンクが表示されない' do
          expect(page).not_to have_link 'Edit'
        end
       end
      end
    end

    context '他人の投稿編集画面' do
      before do
        visit edit_post_path(other_post)

       it '遷移できず、投稿一覧画面にリダイレクトされる' do
        expect(current_path).to eq '/posts'
       end
      end
    end

    describe '他人のユーザ詳細画面のテスト' do
      before do
        visit user_path(other_user)
      end

      context '表示の確認' do
        it 'URLが正しい' do
          expect(current_path).to eq '/users/' + other_user.id.to_s
        end
        it '他人の投稿の画像が表示される' do
          expect(page).to have_content ''
        end
        it '他人の投稿のcontentsが表示される' do
          expect(page).to have_content other_post.contents
        end
        it '他人の投稿のaddressが表示される' do
          expect(page).to have_content other_post.address
        end
        it '自分の投稿は表示されない' do
          expect(page).not_to have_content post.image
          expect(page).not_to have_content post.contents
          expect(page).not_to have_content post.address
        end
      end
    end

    context '他人のユーザ情報編集画面' do
      it '遷移できず、自分のユーザ詳細画面にリダイレクトされる' do
        visit edit_user_path(other_user)
        expect(current_path).to eq '/users/' + user.id.to_s
      end
    end
  end

end