                                  Prefix Verb       URI Pattern                                                                                       Controller#Action
                                                    /ruby_lsp_rails                                                                                   #<RubyLsp::Rails::RackApp:0x00007fe48520fc58>
                           users_sign_in GET        /users/sign_in(.:format)                                                                          passwordless/sessions#new {:authenticatable=>:user, :resource=>:users}
                                         POST       /users/sign_in(.:format)                                                                          passwordless/sessions#create {:authenticatable=>:user, :resource=>:users}
                    verify_users_sign_in GET        /users/sign_in/:id(.:format)                                                                      passwordless/sessions#show {:authenticatable=>:user, :resource=>:users}
                   confirm_users_sign_in GET        /users/sign_in/:id/:token(.:format)                                                               passwordless/sessions#confirm {:authenticatable=>:user, :resource=>:users}
                                         PATCH      /users/sign_in/:id(.:format)                                                                      passwordless/sessions#update {:authenticatable=>:user, :resource=>:users}
                          users_sign_out GET|DELETE /users/sign_out(.:format)                                                                         passwordless/sessions#destroy {:authenticatable=>:user, :resource=>:users}
                                    root GET        /                                                                                                 reminders#new
                         new_user_inputs POST       /new_user_inputs(.:format)                                                                        users#new_inputs
                      remove_user_inputs DELETE     /remove_user_inputs/:email_code(.:format)                                                         users#remove_inputs
                          reminder_users GET        /reminders/:reminder_id/users(.:format)                                                           users#index
                                         POST       /reminders/:reminder_id/users(.:format)                                                           users#create
                       new_reminder_user GET        /reminders/:reminder_id/users/new(.:format)                                                       users#new
                      edit_reminder_user GET        /reminders/:reminder_id/users/:id/edit(.:format)                                                  users#edit
                           reminder_user GET        /reminders/:reminder_id/users/:id(.:format)                                                       users#show
                                         PATCH      /reminders/:reminder_id/users/:id(.:format)                                                       users#update
                                         PUT        /reminders/:reminder_id/users/:id(.:format)                                                       users#update
                                         DELETE     /reminders/:reminder_id/users/:id(.:format)                                                       users#destroy
                        confirm_reminder GET        /reminders/:id/confirm(.:format)                                                                  reminders#confirm
                               reminders GET        /reminders(.:format)                                                                              reminders#index
                                         POST       /reminders(.:format)                                                                              reminders#create
                            new_reminder GET        /reminders/new(.:format)                                                                          reminders#new
                           edit_reminder GET        /reminders/:id/edit(.:format)                                                                     reminders#edit
                                reminder GET        /reminders/:id(.:format)                                                                          reminders#show
                                         PATCH      /reminders/:id(.:format)                                                                          reminders#update
                                         PUT        /reminders/:id(.:format)                                                                          reminders#update
                                         DELETE     /reminders/:id(.:format)                                                                          reminders#destroy
        turbo_recede_historical_location GET        /recede_historical_location(.:format)                                                             turbo/native/navigation#recede
        turbo_resume_historical_location GET        /resume_historical_location(.:format)                                                             turbo/native/navigation#resume
       turbo_refresh_historical_location GET        /refresh_historical_location(.:format)                                                            turbo/native/navigation#refresh
           rails_postmark_inbound_emails POST       /rails/action_mailbox/postmark/inbound_emails(.:format)                                           action_mailbox/ingresses/postmark/inbound_emails#create
              rails_relay_inbound_emails POST       /rails/action_mailbox/relay/inbound_emails(.:format)                                              action_mailbox/ingresses/relay/inbound_emails#create
           rails_sendgrid_inbound_emails POST       /rails/action_mailbox/sendgrid/inbound_emails(.:format)                                           action_mailbox/ingresses/sendgrid/inbound_emails#create
     rails_mandrill_inbound_health_check GET        /rails/action_mailbox/mandrill/inbound_emails(.:format)                                           action_mailbox/ingresses/mandrill/inbound_emails#health_check
           rails_mandrill_inbound_emails POST       /rails/action_mailbox/mandrill/inbound_emails(.:format)                                           action_mailbox/ingresses/mandrill/inbound_emails#create
            rails_mailgun_inbound_emails POST       /rails/action_mailbox/mailgun/inbound_emails/mime(.:format)                                       action_mailbox/ingresses/mailgun/inbound_emails#create
          rails_conductor_inbound_emails GET        /rails/conductor/action_mailbox/inbound_emails(.:format)                                          rails/conductor/action_mailbox/inbound_emails#index
                                         POST       /rails/conductor/action_mailbox/inbound_emails(.:format)                                          rails/conductor/action_mailbox/inbound_emails#create
       new_rails_conductor_inbound_email GET        /rails/conductor/action_mailbox/inbound_emails/new(.:format)                                      rails/conductor/action_mailbox/inbound_emails#new
           rails_conductor_inbound_email GET        /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                                      rails/conductor/action_mailbox/inbound_emails#show
new_rails_conductor_inbound_email_source GET        /rails/conductor/action_mailbox/inbound_emails/sources/new(.:format)                              rails/conductor/action_mailbox/inbound_emails/sources#new
   rails_conductor_inbound_email_sources POST       /rails/conductor/action_mailbox/inbound_emails/sources(.:format)                                  rails/conductor/action_mailbox/inbound_emails/sources#create
   rails_conductor_inbound_email_reroute POST       /rails/conductor/action_mailbox/:inbound_email_id/reroute(.:format)                               rails/conductor/action_mailbox/reroutes#create
rails_conductor_inbound_email_incinerate POST       /rails/conductor/action_mailbox/:inbound_email_id/incinerate(.:format)                            rails/conductor/action_mailbox/incinerates#create
                      rails_service_blob GET        /rails/active_storage/blobs/redirect/:signed_id/*filename(.:format)                               active_storage/blobs/redirect#show
                rails_service_blob_proxy GET        /rails/active_storage/blobs/proxy/:signed_id/*filename(.:format)                                  active_storage/blobs/proxy#show
                                         GET        /rails/active_storage/blobs/:signed_id/*filename(.:format)                                        active_storage/blobs/redirect#show
               rails_blob_representation GET        /rails/active_storage/representations/redirect/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations/redirect#show
         rails_blob_representation_proxy GET        /rails/active_storage/representations/proxy/:signed_blob_id/:variation_key/*filename(.:format)    active_storage/representations/proxy#show
                                         GET        /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)          active_storage/representations/redirect#show
                      rails_disk_service GET        /rails/active_storage/disk/:encoded_key/*filename(.:format)                                       active_storage/disk#show
               update_rails_disk_service PUT        /rails/active_storage/disk/:encoded_token(.:format)                                               active_storage/disk#update
                    rails_direct_uploads POST       /rails/active_storage/direct_uploads(.:format)                                                    active_storage/direct_uploads#create
