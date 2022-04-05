# Copyright:: (c) Autotelik Media Ltd 2011
# Author ::   Tom Statter
# Date ::     Summer 2011
#
# License::   MIT - Free, OpenSource
#
# Details::   Specification for Spree aspect of datashift gem.
#
#             Provides Loaders and rake tasks specifically tailored for uploading or exporting
#             Spree Products, associations and Images
#
require "spec_helper"

require 'product_loader'

describe 'SpreeLoader' do
  
  include_context 'Populate dictionary ready for Product loading'
  
  # Operation and results should be identical when loading multiple associations
  # if using either single column embedded syntax, or one column per entry.

  it "should load Products and multiple Taxons from single column", :taxons => true do
    test_taxon_creation( 'SpreeProducts.xls' )
  end

  it "should load Products and multiple Taxons from multiple columns .xls", :taxons => true do
    test_taxon_creation( 'SpreeProductsMultiColumn.xls' )
  end

  it "should load Products and multiple Taxons from multiple columns CSV", :taxons => true do
    test_taxon_creation( 'SpreeProductsMultiColumn.csv' )
  end
  
  def test_taxon_creation( source )

    # we want to test both find and find_or_create so should already have an object
    # for find
    # want to test both lookup and dynamic creation - this Taxonomy should be found, rest created
    root = Spree::Taxonomy.create( :name => 'Paintings' )
    
    x = root.taxons.create( :name => 'Landscape')
    root.root.children << x
    
    Spree::Taxonomy.count.should == 1
    Spree::Taxon.count.should == 2

    expect(root.root.children.size).to eq 1
    expect(root.root.children[0].name).to eq 'Landscape'

    product_loader =  DataShift::SpreeEcom::ProductLoader.new(ifixture_file(source))

    product_loader.run
    
    expected_multi_column_taxons
  end
  
  def expected_multi_column_taxons

    # Paintings already existed and had 1 child Taxon (Landscape)
    # 2 nested Taxon (Paintings>Nature>Seascape) created under it so expect Taxonomy :
    
    # WaterColour	
    # Oils	
    # Paintings >Nature>Seascape + Paintings>Landscape	
    # Drawings
    
    Spree::Taxonomy.all.collect(&:name).sort.should == ["Drawings", "Oils", "Paintings", "WaterColour"]
       

    expect(Spree::Taxonomy.count).to eq 4
    expect(Spree::Taxon.count).to eq 7

    expect(Spree::Product.count).to eq 3
    
    p = @Variant_klass.where(sku: "DEMO_001").first.product

    expect(p.taxons.size).to eq 2
    p.taxons.collect(&:name).sort.should == ['Paintings','WaterColour']
     
    p2 = @Variant_klass.find_by_sku("DEMO_002").product

    expect(p2.taxons.size).to eq 4
    p2.taxons.collect(&:name).sort.should == ['Nature','Oils','Paintings','Seascape']
     
    paint_parent = Spree::Taxonomy.find_by_name('Paintings')

    expect(paint_parent.taxons.size).to eq 4 # 3 children + all Taxonomies have a root Taxon
    
    paint_parent.taxons.collect(&:name).sort.should == ['Landscape','Nature','Paintings','Seascape']
    
    tn = Spree::Taxon.find_by_name('Nature')    # child with children 
    ts = Spree::Taxon.find_by_name('Seascape')  # last child

    ts.should_not be_nil
    tn.should_not be_nil
    
    p2.taxons.collect( &:id ).should include(ts.id)
    p2.taxons.collect( &:id ).should include(tn.id)

     
    tn.parent.id.should == paint_parent.root.id
    ts.parent.id.should == tn.id

    expect(tn.children.size).to eq 1
    expect(ts.children.size).to eq 0
 
  end
  
  it "should load nested Taxons correctly even when same names from csv", :taxons => true do
    
    Spree::Taxonomy.delete_all
    Spree::Taxon.delete_all    
    
    Spree::Taxonomy.count.should == 0
    Spree::Taxon.count.should == 0

    expected_nested_multi_column_taxons 'SpreeProductsComplexTaxons.xls'
  end

  it "should load nested Taxons correctly even when same names from xls", :taxons => true do
    
    Spree::Taxonomy.delete_all
    Spree::Taxon.delete_all    
    
    Spree::Taxonomy.count.should == 0
    Spree::Taxon.count.should == 0

    expected_nested_multi_column_taxons 'SpreeProductsComplexTaxons.csv'
  end
  
  def expected_nested_multi_column_taxons(source)

    product_loader = DataShift::SpreeEcom::ProductLoader.new(ifixture_file(source) )


    product_loader.run

    # Expected :
    # 2  Paintings>Landscape
    # 1  WaterColour
    # 1  Paintings
    # 1  Oils
    # 2  Drawings>Landscape            - test same name for child (Paintings)
    # 1  Paintings>Nature>Landscape    - test same name for child of a child
    # 1  Landscape	
    # 0  Drawings>Landscape                - test same structure should be reused
    # 2  Paintings>Nature>Seascape->Cliffs - test only the leaf node is created, rest re-used
    # 1  Drawings>Landscape>Bristol        - test a new leaf node created when parent name is same over different taxons
      
    puts Spree::Taxonomy.all.collect(&:name).sort.inspect
    expect(Spree::Taxonomy.count).to eq 5
    
    Spree::Taxonomy.all.collect(&:name).sort.should == ['Drawings', 'Landscape', 'Oils', 'Paintings','WaterColour']
    
    Spree::Taxonomy.all.collect(&:root).collect(&:name).sort.should == ['Drawings', 'Landscape', 'Oils', 'Paintings','WaterColour']
   
    taxons = Spree::Taxon.all.collect(&:name).sort
    
    #puts "#{taxons.inspect} (#{taxons.size})"

    expect(Spree::Taxon.count).to eq 12
   
    taxons.should == ['Bristol', 'Cliffs', 'Drawings', 'Landscape', 'Landscape', 'Landscape', 'Landscape', 'Nature', 'Oils', 'Paintings', 'Seascape','WaterColour']

    # drill down acts_as_nested_set ensure structures correct
    
    # Paintings - Landscape
    #           - Nature
    #                 - Landscape
    #                 - Seascape
    #                     - Cliffs
    painting_onomy = Spree::Taxonomy.find_by_name('Paintings')

    expect(painting_onomy.taxons.size).to eq 6
    painting_onomy.root.child?.should be false
     
    painting = painting_onomy.root

    expect(painting.children.size).to eq 2
    painting.children.collect(&:name).sort.should == ["Landscape", "Nature"]

    expect(painting.descendants.size).to eq 5
    
    lscape = {}
    nature = nil
    
    Spree::Taxon.each_with_level(painting.self_and_descendants) do |t, i|
    
      
      if(t.name == 'Nature')
        nature = t
        i.should == 1
        expect(t.children.size).to eq 2
        t.children.collect(&:name).should == ["Landscape", "Seascape"]

        expect(t.descendants.size).to eq 3
        t.descendants.collect(&:name).sort.should == ["Cliffs", "Landscape", "Seascape"]
    
      elsif(t.name == 'Landscape')
        lscape[i] = t
      end
    end

    nature.should_not be_nil
    
    lscape.size.should be 2
    lscape[1].name.should == 'Landscape'
    lscape[1].parent.id.should == painting.id

    lscape[2].name.should == 'Landscape'
    lscape[2].parent.id.should == nature.id
    
 
    seascape = Spree::Taxon.find_by_name('Seascape')
    expect(seascape.children.size).to eq 1
    seascape.leaf?.should be false
    

    cliffs = Spree::Taxon.find_by_name('Cliffs')
    expect(cliffs.children.size).to eq 0
    cliffs.leaf?.should be true

    Spree::Taxon.find_by_name('Seascape').ancestors.collect(&:name).sort.should == ["Nature", "Paintings"]
    
    # Landscape appears multiple times, under different parents
    expect(Spree::Taxon.where( :name => 'Landscape').size).to eq 4

    # Check the correct Landscape used, Drawings>Landscape>Bristol
    
    drawings = Spree::Taxonomy.where(:name => 'Drawings').first

    expect(drawings.taxons.size).to eq 3
    
    dl = drawings.taxons.find_by_name('Landscape').children

    expect(dl.size).to eq 1
  
    b = dl.find_by_name('Bristol')

    expect(b.children.size).to eq 0
    b.ancestors.collect(&:name).sort.should == ["Drawings", "Landscape"]

    # empty top level taxons
    ['Oils', 'Landscape'].each do |t|
      tx = Spree::Taxonomy.find_by_name(t)
      expect(tx.taxons.size).to eq 1
      tx.root.name.should == t
      expect(tx.root.children.size).to eq 0
      tx.root.leaf?.should be true
    end

  end
  
end
