describe SeabaseApp do
  describe '/' do
    it 'renders' do
      visit '/'
      expect(page.status_code).to eq 200
      expect(page.body).to match 'SeaBase'
    end
    
    it 'searches' do
      visit '/'
      select('Human orthologs', :from => 'scientific_name')
      fill_in('term', :with => 'sox')
      click_button('Search')
      print("#{page.current_url}\n")
      expect(page.status_code).to eq 200
      expect(page.body).to match %q(O00391: Sulfhydryl oxidase 1)
    end
  end

  describe '/blast' do
    it 'renders' do 
      visit '/blast'
      expect(page.status_code).to eq 200
      expect(page.body).to match 'Blast'
    end
  end

  describe '/search' do
    it 'renders' do
      visit '/search'
      expect(page.status_code).to eq 200
      expect(page.body).to match %q(For example 'polymerase alpha', 'P17918')
    end

    context 'html' do
      it 'returns html page' do
        data = [{ term: 'sox',  count: 3 },
                { term: 'Transcription', count: 2},
                { term: 'O95416', count: 1 }]
        data.each do |datum|
          visit('/search?scientific_name=Homo+sapiens'\
                "&term=%s&exact_search=false" % datum[:term])
          expect(page.status_code).to eq 200
          if datum[:count] > 1
            expect(page.body).to match "Found %s items" % datum[:count]
          else
            expect(page.body).not_to match "Found %s items" % datum[:count]
            expect(page.body).to match /homologous.*ortholog SOX14/m
          end
        end
      end
    end

    context 'json' do
      it 'returns results in json' do
        data = [{ term: 'sox', result: ['QSOX1', 'SOX14', 'SOX18'], 
                  field: :gene_name},
                { term: 'Transcription', result: 
                  ['Transcription factor SOX-14', 
                   'Transcription factor SOX-18'], 
                   field: :functional_name },
                { term: 'O95416', result: ['O95416'],
                   field: :name }]

        data.each do |datum|
          visit('/search.json?scientific_name=Homo+sapiens'\
                "&term=%s&exact_search=false" % datum[:term])
          res = JSON.parse(page.body, symbolize_names: true)
          expect(res.map { |d| d[datum[:field]] }.sort).
            to eq datum[:result]
        end
      end

    end
  end

  describe '/external_names' do
    it 'renders' do
      visit '/external_names/25360'
      expect(page.status_code).to eq 200
      expect(page.body).to match 'the human ortholog QSOX1'
    end
  end

  describe '/transcript' do
    it 'renders' do
      visit '/transcript/17065?external_name_id=25360'
      expect(page.status_code).to eq 200
      expect(page.body).to match /transcript comp12135_c0_seq1.+ QSOX1/m
    end
  end
  
end


