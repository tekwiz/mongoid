require "spec_helper"

describe Mongoid::Relations::Builders::Referenced::One do

  let(:base) do
    double(new_record?: false)
  end

  describe "#build" do

    let(:criteria) do
      Post.where("person_id" => object)
    end

    let(:metadata) do
      double(
        klass: Post,
        name: :post,
        foreign_key: "person_id",
        criteria: criteria,
        inverse_klass: Person
      )
    end

    let(:builder) do
      described_class.new(base, metadata, object)
    end

    context "when provided an id" do

      let(:object_id) do
        Moped::BSON::ObjectId.new
      end

      let(:object) do
        object_id
      end

      let(:post) do
        double
      end

      before do
        criteria.should_receive(:first).and_return(post)
      end

      let!(:documents) do
        builder.build
      end

      it "sets the document" do
        expect(documents).to eq(post)
      end
    end

    context "when provided a object" do

      let(:object) do
        Post.new
      end

      let(:document) do
        builder.build
      end

      it "returns the object" do
        expect(document).to eq(object)
      end
    end
  end

  describe "#build" do

    let(:person) do
      Person.new
    end

    context "when the document is not found" do

      it "returns nil" do
        expect(person.game).to be_nil
      end
    end

    context "when the document is persisted" do

      before do
        Mongoid.identity_map_enabled = true
        person.save
      end

      after do
        Mongoid.identity_map_enabled = false
      end

      let!(:game) do
        Game.create(person_id: person.id)
      end

      it "returns the document" do
        expect(person.game).to eq(game)
      end

      it "pulls the document from the identity map" do
        expect(person.game).to equal(game)
      end
    end

    context "when the document have a non standard pk" do

      before do
        person.save
      end

      let!(:cat) do
        Cat.create(person_id: person.username)
      end

      it "returns the document" do
        expect(person.cat).to eq(cat)
      end
    end
  end
end
