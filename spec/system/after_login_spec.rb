require 'rails_helper'

describe '[STEP2] ユーザログイン後のテスト' do
  let(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:post) { create(:post, user: user) }
  let!(:other_post) { create(:post, user: other_user) }

  before do
    visit new_user_session_path
    fill_in 'user[name]', with: user.name
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: user.password
    click_button 'ログイン'
  end

  describe 'ヘッダーのテスト: ログインしている場合' do
    context 'リンクの内容を確認: ※logoutは『ユーザログアウトのテスト』でテスト済みになります。' do
      subject { current_path }

      it 'topを押すと、postの一覧画面に遷移する' do
        click_link 'top'
        is_expected.to eq '/posts'
      end
      it 'ユーザーを押すと、ユーザ一覧画面に遷移する' do
        click_link 'ユーザー'
        is_expected.to eq '/users'
      end
      it '新規投稿を押すと、新規登録画面に遷移する' do
        click_link '新規投稿'
        is_expected.to eq '/posts/new'
      end
      it 'マイページを押すと、ユーザー詳細画面に遷移する' do
        click_link 'マイページ'
        is_expected.to eq '/users/' + user.id.to_s
      end
    end
  end

  describe '投稿一覧画面のテスト' do
    before do
      visit posts_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/posts'
      end
      it '自分の投稿画像と他人の投稿画像のリンク先がそれぞれ正しい' do
        expect(page).to have_link '', href: post_path(post)
        expect(page).to have_link '', href: post_path(other_post)
      end
      it '自分の投稿と他人の投稿のオピニオンが表示される' do
        expect(page).to have_content post.contents
        expect(page).to have_content other_post.contents
      end
    end
  end

  describe '新規登録画面のテスト' do
    before do
      visit new_post_path
    end

    context '表示内容の確認' do
      it '「新規投稿」と表示される' do
        expect(page).to have_content '新規投稿'
      end
      it '画像選択フォームが表示される' do
        expect(page).to have_field 'post[image]'
      end
      it 'contentsフォームが表示される' do
        expect(page).to have_field 'post[contents]'
      end
      it 'contentsフォームに値が入っていない' do
        expect(find_field('post[contents]').text).to be_blank
      end
      it 'addressフォームが表示される' do
        expect(page).to have_field 'post[address]'
      end
      it 'addressフォームに値が入っていない' do
        expect(find_field('post[address]').text).to be_blank
      end
      it '投稿ボタンが表示される' do
        expect(page).to have_button '投稿する'
      end
    end

    context '投稿成功のテスト' do
      before do
        it '自分の新しい投稿が正しく保存される' do
         attach_file('post[image]', "#{Rails.root}/spec/fixture/AME619sentaihikou_TP_V4.jpg", make_visible: true)
         fill_in 'post[contents]', with: Faker::Lorem.characters(number: 10)
         fill_in 'post[address]', with: Faker::Lorem.characters(number: 10)
         fill_in 'post.map[latitude]', with: Faker::Lorem.characters(number: 10)
         fill_in 'post.map[longitude]', with: Faker::Lorem.characters(number: 10)
         expect { click_button '投稿する' }.to change(user.posts, :count).by(1)
       end
       it 'リダイレクト先が、投稿詳細画面になっている' do
        click_button '投稿する'
        expect(page).to eq '/posts/' + post.id.to_s
       end

      end
    end
  end

  describe '自分の投稿詳細画面のテスト' do
    before do
      visit post_path(post)


     context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/posts/' + post.id.to_s
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
      it '投稿の編集リンクが表示される' do
        expect(page).to have_link '編集', href: edit_post_path(post)
      end
     end

     context '編集リンクのテスト' do
      it '編集画面に遷移する' do
        click_link '編集'
        expect(current_path).to eq '/posts/' + post.id.to_s + '/edit'
      end
     end
    end
  end

  describe '自分の投稿編集画面のテスト' do
    before do
      visit edit_post_path(post)

     context '表示の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/posts/' + post.id.to_s + '/edit'
      end
      it '「投稿編集」と表示される' do
        expect(page).to have_content '投稿編集'
      end
      it 'ユーザ名前が表示される' do
        expect(page).to have_content post.user.name
      end
      it '画像の編集フォームが表示される' do
        expect(page).to have_field 'post[image]', with: post.image
      end
      it 'contents編集フォームが表示される' do
        expect(page).to have_field 'post[contents]', with: post.contents
      end
      it 'address編集フォームが表示される' do
        expect(page).to have_field 'post[address]', with: post.address
      end
      it '編集ボタンが表示される' do
        expect(page).to have_button '変更する'
      end
      it '投稿の削除リンクが表示される' do
        expect(page).to have_link '投稿を削除', href: post_path(post)
      end
     end

     context '編集成功のテスト' do
      before do
        @post_old_image = post.image
        @post_old_contents = post.contents
        @post_old_address = post.address
        image_path = Rails.root.join('public/images/no_image.jpg')
        attach_file('desk[image]', image_path, make_visible: true)
        fill_in 'post[contents]', with: Faker::Lorem.characters(number: 10)
        fill_in 'post[address]', with: Faker::Lorem.characters(number: 10)
        click_button '変更する'

       it '画面が正しく更新される' do
        expect(post.reload.image).not_to eq @post_old_image
       end
       it 'contentsが正しく更新される' do
        expect(post.reload.contents).not_to eq @post_old_contents
       end
       it 'addressが正しく更新される' do
        expect(post.reload.address).not_to eq @post_old_address
       end
       it 'リダイレクト先が、更新した投稿の詳細画面になっている' do
        expect(current_path).to eq '/posts/' + posts.id.to_s
        expect(page).to have_content post.user.name
       end
      end
     end
    end
  end

  describe 'ユーザ一覧画面のテスト' do
    before do
      visit users_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/users'
      end
      it '自分と他人の名前がそれぞれ表示される' do
        expect(page).to have_content user.name
        expect(page).to have_content other_user.name
      end
      it 'showリンクがそれぞれ表示される' do
        expect(page).to have_link user.name, href: user_path(user)
      end
    end
  end

  describe '自分のユーザ詳細画面のテスト' do
    before do
      visit user_path(user)
    end

    context '表示の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/users/' + user.id.to_s
      end
      it '投稿一覧に自分の投稿の画面が表示され、リンクが正しい' do
        expect(page).to have_link '', href: post_path(post)
      end
      it '投稿一覧に自分の投稿のcontentsが表示される' do
        expect(page).to have_content post.contents
      end
      it '他人の投稿は表示されない' do
        expect(page).not_to have_link '', href: user_path(other_user)
        expect(page).not_to have_content other_post.contents
      end
    end
  end

  describe '自分のユーザ情報編集画面のテスト' do
    before do
      visit edit_user_path(user)


     context '表示の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/users/' + user.id.to_s + '/edit'
      end
      it '名前編集フォームに自分の名前が表示される' do
        expect(page).to have_field 'user[name]', with: user.name
      end
      it '画像編集フォームが表示される' do
        expect(page).to have_field 'user[image]'
      end
      it '自己紹介編集フォームに自分の自己紹介文が表示される' do
        expect(page).to have_field 'user[introduction]', with: user.introduction
      end
      it 'Update Userボタンが表示される' do
        expect(page).to have_button '変更する'
      end
     end

     context '更新成功のテスト' do
      before do
        @user_old_intrpduction = user.introduction
        fill_in 'user[introduction]', with: Faker::Lorem.characters(number: 15)
        click_button '変更する'
      end

      it 'introductionが正しく更新される' do
        expect(user.reload.introduction).not_to eq @user_old_intrpduction
      end
      it 'リダイレクト先が、自分のユーザ詳細画面になっている' do
        expect(current_path).to eq '/users/' + user.id.to_s
      end
     end
    end
  end
end