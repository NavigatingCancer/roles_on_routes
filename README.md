# Important Note!!!!
This repository has been archived and collapsed into GC as of November 2nd 2023.
Please see https://github.com/NavigatingCancer/gc/tree/develop/nc_gems/roles_on_routes for any future changes


# Roles On Routes

Roles On Routes was written by Navigating Cancer.

It allows defining user roles for authorization directly on the routes to which they apply.

WARNING:

link_to_with_roles, div_with_roles, li_with_roles, tr_with_roles, td_with_roles, ul_with_roles, and ol_with_roles use JavaScript to hide html after the page has loaded client-side. They should not be used. (See tags_with_roles.rb and gc/app/assets/javascripts/clinic/staff_landing.js.coffee.)

## Running Tests
`bundle exec rspec`
