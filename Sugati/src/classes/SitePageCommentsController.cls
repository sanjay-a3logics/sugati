public without sharing class SitePageCommentsController{

    public string oppId{get;set;}
    public Opportunity opp{get;set;}
    public List<Note> notes {get; set;}
    private List<RowWrapper> rows;

    public SitePageCommentsController() {
        try {
            
            oppId = Apexpages.currentPage().getParameters().get('id');
            System.debug(Apexpages.currentPage().getParameters().get('id'));
            if (oppId != null) {
                    
            }
        }
        Catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()+'--'+e.getStackTraceString()));
            //throw e;
        }
        
        
    }
    
    // retrieves the list of row wrappers
public List<RowWrapper> getRowWrappers()
{
    notes= [select id, title, body, createddate from Note where parentid =: oppId order by createddate desc];
   
        rows=new List<RowWrapper>();
        Integer idx = 0;
        Integer cnt = 0;
        Integer md = 0;
        for (Note nt : notes)
        {
            rows.add(new RowWrapper());
            rows[cnt+0].addValue('"' + notes[idx].body + '"');
            rows.add(new RowWrapper());
            rows[cnt+1].addValue(' ');
            rows.add(new RowWrapper());
            rows[cnt+2].addValue('<b>' + notes[idx].title + '</b>' );
            rows.add(new RowWrapper());
            rows[cnt+3].addValue('<hr/> ');
            rows.add(new RowWrapper());
            rows[cnt+4].addValue(' ');
            idx ++;
            if(math.mod(idx,2)==0)
            {
                cnt=cnt+5;
            }
        }
    
     
    return rows;
}
    public void reload(){
        //System.assert(false,getRowWrappers().size());
    }
    
    
    public class RowWrapper
    {
     // the values (cells) making up this row
     public List<String> values {get; set;}
      
     // constructor
     public RowWrapper()
     {
      values=new List<String>();
     }
      
     // append a value (cell) to the row
     public void addValue(String value)
     {
      values.add(value);
     }
    }

}