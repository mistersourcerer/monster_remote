module Monster
  module Remote

    describe Sync do

      let(:wrapper) { double("wrapper").as_null_object }
      let(:sync) { Sync.new(wrapper) }

      context "#start" do

        it "raise error if asked to start without protocol provider" do
          error = Monster::Remote::MissingProtocolWrapperError
          lambda { Sync.new(nil).start }.should raise_error(error)
        end

        # abre conexao
        it "call wrapper's #open" do
          wrapper.should_receive(:open)
          sync.start
        end

        # se der error exception
        # se der certo
        # espelha estrutura de dirs local e manda os arquivos
        # # recursivamente até terminar
      end# #start
    end# Sync
  end
end
