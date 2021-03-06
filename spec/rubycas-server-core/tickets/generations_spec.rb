require "spec_helper"

module RubyCAS::Server::Core::Tickets
  describe RubyCAS::Server::Core::Tickets::Generations do
    let(:client_hostname) { 'myhost.test' }
    let(:username) { 'myuser' }
    let(:service) { 'https://myservice.test' }

    before do
      RubyCAS::Server::Core.setup("spec/config/config.yml")
      @generations = Class.new
      @generations.extend(RubyCAS::Server::Core::Tickets::Generations)
    end

    describe '.generate_login_ticket(client_hostname)' do
      before do
        @lt = @generations.generate_login_ticket(client_hostname)
      end

      it "should return a login ticket" do
        @lt.class.should == LoginTicket
      end

      it "should set the client_hostname" do
        @lt.client_hostname.should == client_hostname
      end

      it "should set the ticket string" do
        @lt.ticket.should_not be_nil
      end

      it "should set the ticket string starting with 'LT'" do
        @lt.ticket.should(match(/^LT/))
      end

      it "should not mark the ticket as consumed" do
        @lt.consumed.should be_nil
      end
    end

    describe ".generate_ticket_granting_ticket(username, extra_attributes = {})" do
      before do
        @tgt = @generations.generate_ticket_granting_ticket(username, client_hostname)
      end

      it "should return a TicketGrantingTicket" do
        @tgt.class.should == TicketGrantingTicket
      end

      it "should set the tgt's ticket string" do
        @tgt.ticket.should_not be_nil
      end

      it "should generate a ticket string starting with 'TGC'" do
        @tgt.ticket.should(match(/^TGC/))
      end

      it "should set the tgt's username string" do
        @tgt.username.should == username
      end

      it "should set the tgt's client_hostname" do
        @tgt.client_hostname.should == client_hostname
      end
    end

    describe ".generate_service_ticket(service, username, tgt)" do
      before do
        @tgt = @generations.generate_ticket_granting_ticket(username, client_hostname)
        @st = @generations.generate_service_ticket(service, username, @tgt, client_hostname)
      end

      it "should return a ServiceTicket" do
        @st.class.should == ServiceTicket
      end

      it "should not include the service identifer in the ticket string" do
        @st.ticket.should_not(match(/#{service}/))
      end

      it "should not mark the ST as consumed" do
        @st.consumed.should be_nil
      end

      it "must generate a ticket that starts with 'ST-'" do
        @st.ticket.should(match(/^ST-/))
      end

      it "should assoicate the ST with the supplied TGT" do
        @st.ticket_granting_ticket.id.should == @tgt.id
      end
    end

    describe ".generate_proxy_ticket(target_service, pgt)" do
      it "should return a ProxyGrantingTicket" do
        skip('Not supported')
      end

      it "should not consume the generated ticket" do
        skip('Not supported')
      end

      it "should start the ticket string with PT-" do
        skip('Not supported')
      end
    end
  end
end

