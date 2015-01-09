require 'rubycas-server-core/util'

module RubyCAS
  module Server
    module Core
      module Tickets

        class LT
          include ::RubyCAS::Server::Core
          include ::RubyCAS::Server::Core::Tickets
          extend ::RubyCAS::Server::Core::Tickets::Validations

          def self.create!(client = "localhost")
            lt = Tickets.generate_login_ticket(client)
            raise 'error that should be handled by rubycas-server-core gem' if !lt
            return lt
          end

          def self.create(client = "localhost")
            Tickets.generate_login_ticket(client)
          end

          def self.validate(lt)
            validate_login_ticket(lt)
          end

          def self.find_by(options)
            Tickets::LoginTicket.find_by(
              options
            )
          end

          def self.find_by!(options)
            lt = Tickets::LoginTicket.find_by(
              options
            )
            raise 'error that should be handled by rubycas-server-core gem' if !lt
            return lt
          end
        end

        class TGT
          include ::RubyCAS::Server::Core
          include ::RubyCAS::Server::Core::Tickets
          extend ::RubyCAS::Server::Core::Tickets::Validations

          def self.create!(user, client = "localhost", remember_me = false, extra_attributes)
            tgt = Tickets.generate_ticket_granting_ticket(
              user, client, remember_me, extra_attributes
            )
            raise 'error that should be handled by rubycas-server-core gem' if !tgt
            return tgt
          end

          def self.create(user, client = "localhost", remember_me = false, extra_attributes)
            Tickets.generate_ticket_granting_ticket(
              user, client, remember_me, extra_attributes
            )
          end

          def self.validate(tgt)
            validate_ticket_granting_ticket(tgt)
          end


          def self.find_by(options)
            Tickets::TicketGrantingTicket.find_by(
              options
            )
          end

          def self.find_by!(options)
            tgt = Tickets::TicketGrantingTicket.find_by(
              options
            )
            raise 'error that should be handled by rubycas-server-core gem' if !tgt
            return tgt
          end
        end

        class ST
          include ::RubyCAS::Server::Core
          include ::RubyCAS::Server::Core::Tickets
          extend ::RubyCAS::Server::Core::Tickets::Validations

          def self.create!(service, user, tgt, client="localhost")
            st = Tickets.generate_service_ticket(service, user, tgt, client)
            raise 'error that should be handled by rubycas-server-core gem' if !st
            return st
          end

          def self.create(service, user, tgt, client="localhost")
            Tickets.generate_service_ticket(service, user, tgt, client)
          end

          def self.validate(service, ticket)
            validate_service_ticket(service, ticket)
          end

          def self.find_by(options)
            Tickets::ServiceTicket.find_by(
              options
            )
          end

          def self.find_by!(options)
            st = Tickets::ServiceTicket.find_by(
              options
            )
            raise 'error that should be handled by rubycas-server-core gem' if !st
            return st
          end
        end

        class Utils
          include ::RubyCAS::Server::Core

          def self.clean_service_url(service_url)
            return "" if service_url.nil?
            service_url.encode!('UTF-16', 'UTF-8', invalid: :replace, replace: '')
            service_url.encode!('UTF-8', 'UTF-16')
            Util.clean_service_url(service_url)
          end

          def self.build_ticketed_url(service, ticket)
            Util.build_ticketed_url(service, ticket)
          end
        end


        # One time login ticket for given client
        def self.generate_login_ticket(client)
          lt = LoginTicket.new
          lt.ticket = "LT-" + Util.random_string
          lt.client_hostname = client
          if lt.save!
            $LOG.debug("Login ticket '#{lt.ticket} has been created for '#{lt.client_hostname}'")
            return lt
          else
            return nil
          end
        end

        # Creates a TicketGrantingTicket for the given username. This is done when the user logs in
        # for the first time to establish their SSO session (after their credentials have been validated).
        #
        # The optional 'extra_attributes' parameter takes a hash of additional attributes
        # that will be sent along with the username in the CAS response to subsequent
        # validation requests from clients.
        def self.generate_ticket_granting_ticket(
          username,
          client,
          remember_me = false,
          extra_attributes = {}
        )
          tgt = TicketGrantingTicket.new
          tgt.ticket = "TGC-" + Util.random_string
          tgt.username = username
          tgt.remember_me = remember_me
          tgt.extra_attributes = extra_attributes.to_s
          tgt.client_hostname = client
          if tgt.save!
            $LOG.debug("Generated ticket granting ticket '#{tgt.ticket}' for user" +
              " '#{tgt.username}' at '#{tgt.client_hostname}'" +
              (extra_attributes.empty? ? "" : " with extra attributes #{extra_attributes.inspect}"))
            return tgt
          else
            return nil
          end
        end

        def self.generate_service_ticket(service, username, tgt, client)
          st = tgt.service_tickets.new
          st.ticket = "ST-" + Util.random_string
          st.service = service
          st.username = username
          st.ticket_granting_ticket = tgt
          st.client_hostname = client
          if st.save
            $LOG.debug("Generated service ticket '#{st.ticket}' for service '#{st.service}'" +
              " for user '#{st.username}' at '#{st.client_hostname}'")
            return st
          else
            return nil
          end
        end

        def self.generate_proxy_ticket(target_service, pgt, client)
          raise NotImplementedError
        end

        def self.generate_proxy_granting_ticket(pgt_url, st, client)
          raise NotImplementedError
        end
      end
    end
  end
end
