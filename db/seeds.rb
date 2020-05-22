# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Admin.create(email: "admin@email.com",
             password: "password",
             password_confirmation: "password"
            )

User.create(name: "tester",
            email: "tester@email.com",
            password: "password",
            password_confirmation: "password",
            nickname: "tester",
            gender: "male"
           )

StoreManager.create(email: "store_manager@email.com",
                    name: "store_manager",
                    password: "password"
                   )

Store.create(store_name: "abc_store",
             adress: "japan-aichi-nagoya",
             store_phonenumber: "08012345678",
             store_description: "テストの解説aaaaaaaa",
             store_manager_id: 1
            )

Masseur.create(masseur_name: "cororo",
               email: "cororo@email.com",
               password: "password",
               password_confirmation: "password",
               store_id: 1
              )

Favorite.create(user_id: 1,
                masseur_id: 1
               )

Review.create(review: "so good",
               rate: 3.5,
               user_id: 1,
               masseur_id: 1
               )

Category.create(category_name: "オステオパシー"
               )

MasseurCategory.create(
                       masseur_id: 1,
                       category_id: 1,
                      )

            
5.times do |n|
  plan_name  = plan_name,
  plan_content = plan_content,
  plan_time = plan_time
  Plan.create!(plan_name: "プラン#{n+1}",
               plan_content: "PCやスマートフォンを使ったり鞄を持ったりと、日常の疲れが溜まりやすい肘から下をもみほぐす【ハンドリフレ】。肩や目が疲れやすい方に、頭から首にかけてもみほぐす【クイックヘッド】。ストレスが溜まりやすい方や頭からスッキリとリラックスしたい方にオススメ。",
               plan_time: 100,
               plan_price: 4500,
               store_id: 1)
end