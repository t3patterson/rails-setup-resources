#SETUP SCRIPT DOES THE FOLLOWING:
# 0) In command line `$ bash rsetup.sh`
#     - Creates a new rails project w/ postgresql db by default
#
# 1) Adds the following gems to Gemfile:
#     - bootstrap
#     - faker
#     - simple_form
#     - rails12factor
#     - underscore
#     - minitest-rails (including )
#         for :development and :test groups
#           - minitest-rails-capybara
#           - minitest-reporters 
#           - launchy
#           
# 2) Bundles gems
# 
# 
# 3) Requires underscore in `application.js` magic comments 
# 
# 4) change filename : `application.css` to `application.scss`
#           @import 'bootstrap' 
#           @import 'bootstrap-sprockets'
#           
# 5) download boilerplate css and inject it into `application.scss` file     
# 

insert_after(){
  STRMATCH=$1
  PRINTVAL=$2
  FILENAME=$3

  awk "/$STRMATCH/{print;print \"$PRINTVAL\";next}1" $FILENAME > ./somewhere.tmp && mv ./somewhere.tmp $FILENAME   
}

echo "-------------------------"
echo "New Project -------------"
echo "-------------------------"

echo "-------------------------"
echo $1
echo "-------------------------"

#Sets up new rails project
rails new $1 --database=postgresql

#Define Paths from ROOT Directory
JS_PATH="./app/assets/javascripts/"
CSS_PATH="./app/assets/stylesheets/"

#Changes Into ROOT Directory for project
cd $1

#Activate Gems: bcrypt, therubyracer, 
sed -i "" "s/# gem 'bcrypt/gem 'bcrypt/g" Gemfile
sed -i "" "s/# gem 'therubyracer'/gem 'therubyracer'/g" Gemfile
sed -i "" "s/# gem 'jbuilder'/gem 'jbuilder'/g" Gemfile

#Deactivate turbolinks
sed -i "" "s/gem 'turbolinks'/# gem 'turbolinks'/g" Gemfile


#Add Standard Gems
echo "gem 'faker'"  >> Gemfile
echo "gem 'simple_form'" >> Gemfile
echo "gem 'bootstrap-sass', '~> 3.3.5'" >> Gemfile
echo "gem 'rails_12factor'" >> Gemfile
echo "gem 'underscore-rails'" >> Gemfile

#Add React to the Gemlist
echo "gem 'react-rails', '~> 1.5.0'" >> Gemfile

#Add refile to the gemlist
echo "gem 'refile', require: 'refile/rails'" >> Gemfile
echo "gem 'refile-mini_magick'" >> Gemfile
echo "gem 'refile-postgres'" >> Gemfile

#Add payola & figaro
echo "gem 'payola-payments'" >> Gemfile
echo "gem 'figaro'" >> Gemfile


# Add Minitest to the gemlist
echo "gem 'minitest-rails'" >> Gemfile

#  Adds minitest-rails addons to the :development and :test groups
gemlist=(
  "  gem 'pry'"
  "  gem 'minitest-reporters'" 
  "  gem 'minitest-rails-capybara'" 
)

buildit=""
for i in "${gemlist[@]}" ; do
 buildit="$i\n$buildit"
done

insert_after 'group :development, :test do' "$buildit"  ./Gemfile

bundle install
# Configure Magic comments

JS_PATH="./app/assets/javascripts/"
CSS_PATH="./app/assets/stylesheets/"

########
###add magic comments to requires
########

sed '\/\/= require turbolinks/a\
//= require components
' $JS_PATH/application.js > $JS_PATH/application2.js;
mv $JS_PATH/application2.js $JS_PATH/application.js;

sed '\/\/= require turbolinks/a\
//= require react_ujs
# ' $JS_PATH/application.js > $JS_PATH/application2.js;
mv $JS_PATH/application2.js $JS_PATH/application.js;

sed '\/\/= require turbolinks/a\
//= require react
# ' $JS_PATH/application.js > $JS_PATH/application2.js;
mv $JS_PATH/application2.js $JS_PATH/application.js;

sed '\/\/= require turbolinks/a\
//= require bootstrap
# ' $JS_PATH/application.js > $JS_PATH/application2.js;
mv $JS_PATH/application2.js $JS_PATH/application.js;

sed '\/\/= require turbolinks/a\
//= require moment
# ' $JS_PATH/application.js > $JS_PATH/application2.js;
mv $JS_PATH/application2.js $JS_PATH/application.js;

sed '\/\/= require turbolinks/a\
//= require underscore
# ' $JS_PATH/application.js > $JS_PATH/application2.js;
mv $JS_PATH/application2.js $JS_PATH/application.js;

########
###Setup Bootstrap
########
mv $CSS_PATH/application.css $CSS_PATH/application.scss
echo "@import 'bootstrap-sprockets';" >> $CSS_PATH/application.scss
echo "@import 'bootstrap';" >> $CSS_PATH/application.scss

########
#install & configure react
########
rails g react:install

awk '/^end$/{print "\n  config.react.variant = :development"}1' ./config/environments/development.rb > ./temptemp.tmp && mv temptemp.tmp ./config/environments/development.rb
awk '/^end$/{print "\n  config.react.variant = :production"}1' ./config/environments/production.rb > ./temptemp.tmp && mv temptemp.tmp ./config/environments/production.rb

########
#####setup the database
########
rake db:create

########
#initializers/migration file for refile
########
# rails g refile:postgres:migration
# rails g refile:postgres:initializers

########
#payola initializer
######### 
# rails g payola:install


########
#rake db
########
rake db:migrate

#########
###boilerplate css
######### 
echo "downloading boilerplate css..."
curl https://raw.githubusercontent.com/t3patterson/rails-setup-resources/master/boilerplate.scss >> $CSS_PATH/application.scss

########
###JS-momentjs
######### 
echo "downloading momentjs"
curl http://momentjs.com/downloads/moment.min.js > ./vendor/assets/javascripts/moment.min.js

# echo "...css & js downloads complete"