selected_password = ENV.fetch('PASSWORD', 'testing123')

muppet_upload = upload('muppets.mp3')
piano_upload = upload('piano.mp3')
andy_upload = upload('titleless.mp3')

sudara_avatar_upload = upload('jeffdoessudara.jpg')
marie_avatar_upload = upload('marie.jpg')

manfred_cover_upload = upload('manfreddoescover.jpg')
blue_de_bresse_upload = upload('blue_de_bresse.jpg')
cheshire_cheese_upload = upload('cheshire_cheese.jpg')


# Create admin account.
admin_password = selected_password
admin = User.create!(
  login: 'owner',
  email: 'owner@example.com',
  password: admin_password,
  password_confirmation: admin_password,
  admin: true,
  current_login_ip: 'fc00:1:1::1'
)
put_user_credentials(admin.login, admin_password)

# Create moderator account.
moderator_password = selected_password
moderator = User.create!(
  login: 'moderator',
  email: 'moderator@example.com',
  password: moderator_password,
  password_confirmation: moderator_password,
  moderator: true,
  current_login_ip: 'fc00:1:1::2',
  avatar_image: sudara_avatar_upload
)
put_user_credentials(moderator.login, moderator_password)
moderator.profile.update(
  country: 'Austria'
)

# Create regular musician account.
musician_password = selected_password
musician = User.create!(
  login: 'musician',
  email: 'musician@example.com',
  password: musician_password,
  password_confirmation: musician_password,
  current_login_ip: 'fc00:1:1::3'
)
put_user_credentials(musician.login, musician_password)

# --- Marieh ---

marie_password = selected_password
marie = User.create!(
  login: 'marieh',
  email: 'marie.harel@example.com',
  password: marie_password,
  password_confirmation: marie_password,
  current_login_ip: 'fc00:1:1::4',
  avatar_image: marie_avatar_upload
)
put_user_credentials(marie.login, marie_password)
marie.profile.update(
  bio: 'The phrase is not commonly used to describe the colour of a cheese, though there are some cheeses with a greenish tint, usually from mold or added herbs.',
  country: 'Spain',
  city: 'Madrid'
)

commonly_blue_green = marie.assets.create!(extract_metadata(
  audio_file: piano_upload,
  title: 'Commonly Blue-grey',
  description: 'The color of camembert rind was a matter of chance, most commonly blue-grey, with brown spots.'
))
aqueous_suspension = marie.assets.create!(extract_metadata(
  audio_file: muppet_upload,
  title: 'Aqueous Suspension',
  description: 'The surface of each cheese is then sprayed with an aqueous suspension of the mold Penicillium camemberti.'
))

playlist = marie.playlists.build(
  title: 'Before fungi were understood',
  year: Date.today.year - 1,
  cover_image: manfred_cover_upload
)
playlist.credits = <<~DESC
  The variety named Camembert de Normandie was granted a protected designation of origin in 1992
  after the original AOC in 1983.
DESC
playlist.save!
playlist.tracks.create!(user: marie, asset: commonly_blue_green)
playlist.tracks.create!(user: marie, asset: aqueous_suspension)
playlist.publish!

baguette_laonnaise = marie.assets.create!(extract_metadata(
  audio_file: andy_upload,
  title: 'Baguette Laonnaise',
  description: 'The cheese is typically loaf-shaped and has a supple interior as well as a sticky orange-brown rind.'
))
appellation_description = marie.assets.create!(extract_metadata(
  audio_file: piano_upload,
  title: 'Appellation description d’origine protégée',
  description: 'In Switzerland, the appellation d’origine protégée (AOP, protected designation of origin) is a geographical indication protecting the origin and the quality of traditional food products'
))

playlist = marie.playlists.build(
  title: 'Raclette',
  year: Date.today.year
)
playlist.credits = <<~DESC
  Raclette /rəˈklɛt/ is a semi-hard cheese that is usually fashioned into a wheel of about
  6 kg (13 lb).
DESC
playlist.save!
playlist.tracks.create!(user: marie, asset: baguette_laonnaise)
playlist.tracks.create!(user: marie, asset: appellation_description)
playlist.publish!

# --- Carole ---

carole_password = selected_password
carole = User.create!(
  login: 'carole',
  email: 'carole.koshin@example.com',
  password: carole_password,
  password_confirmation: carole_password,
  current_login_ip: 'fc00:1:1::5'
)
put_user_credentials(carole.login, carole_password)
carole.profile.update(
  bio: 'Though it was started primarily by Switzerland, France, and Italy, who also happen to dominate its awards, there are typically over 100 entries, from all over the world, including Japan, Mexico, and Ethiopia.',
  country: 'United States',
  city: 'Perth'
)

creamy_interior = carole.assets.create!(extract_metadata(
  audio_file: muppet_upload,
  title: 'Creamy Interior',
  description: 'Contains patches of blue mold'
))
cylindrical_rounds = carole.assets.create!(extract_metadata(
  audio_file: muppet_upload,
  title: 'Cylindrical Rounds',
  description: 'It is shaped into cylindrical rounds weighing from 125 to 500 grams.'
))

edible_coating = carole.playlists.build(
  title: 'Edible Coating',
  year: Date.today.year,
  cover_image: blue_de_bresse_upload
)
edible_coating.credits = <<~DESC
  Edible coating which is characteristically white in color and has an aroma of mushrooms.
DESC
edible_coating.save!
edible_coating.tracks.create!(user: carole, asset: creamy_interior)
edible_coating.tracks.create!(user: carole, asset: cylindrical_rounds)
edible_coating.publish!

# --- Petere ---

petere_password = selected_password
petere = User.create!(
  login: 'petere',
  display_name: 'Petere 🐺',
  email: 'petere.appleby@example.com',
  password: petere_password,
  password_confirmation: petere_password,
  current_login_ip: 'fc00:1:1::6'
)
put_user_credentials(petere.login, petere_password)
petere.profile.update(
  country: 'Norway',
  city: 'Medjå'
)

keep_tradition_alive = petere.assets.create!(extract_metadata(
  audio_file: muppet_upload,
  title: 'Keep Tradition Alive',
  description: 'Cloth-bound Cheshire cheeses from their own unpasteurised milk'
))
much_like_cheddar = petere.assets.create!(extract_metadata(
  audio_file: muppet_upload,
  title: 'Much Like Cheddar',
  description: 'Cheshire cheese is made much like cheddar (now the name of a process, rather than a geographical designation) or Lancashire'
))

mrs_applebys_cheshire = petere.playlists.build(
  title: "Mrs Appleby's Cheshire",
  year: Date.today.year - 2,
  cover_image: cheshire_cheese_upload
)
mrs_applebys_cheshire.credits = <<~DESC
  Edible coating which is characteristically white in color and has an aroma of mushrooms.
DESC
mrs_applebys_cheshire.save!
mrs_applebys_cheshire.tracks.create!(user: petere, asset: keep_tradition_alive)
mrs_applebys_cheshire.tracks.create!(user: petere, asset: much_like_cheddar)
mrs_applebys_cheshire.publish!