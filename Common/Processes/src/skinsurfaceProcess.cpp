#include "Saxana/ProcessingConfigurator.h"
#include "Saxana/ProcessingContext.h"
#include "Saxana/SAXProcessor.h"
#include "Saxana/StateStack.h"
#include "Saxana/SAXProcessingState.h"
#include "Saxana/SAXStateProcess.h"
#include "Saxana/SAXObjectHandle.h"
#include "Saxana/SAXComponentFactory.h"

#include "Schema/skinsurface.h"
#include "Processes/LogicalSurfaceTypeProcess.h"

#include <cstdlib>
#include <iostream>

class skinsurfaceProcess : public LogicalSurfaceTypeProcess
{
public:
  skinsurfaceProcess( const ProcessingContext* context = 0 )
  : LogicalSurfaceTypeProcess( context ) {
  }
  
  virtual ~skinsurfaceProcess() {
  }
  
  virtual const SAXComponentObject* Build() const {
    return this;
  }

  // Analogical to SAX startElement callback
  virtual void StartElement( const std::string& name, const ASCIIAttributeList& attrs )
  {     
    SAXObject** obj = Context()->GetTopObject();

    skinsurface* skinsurface_element = new skinsurface;
    m_obj = skinsurface_element;
    *obj  = skinsurface_element;

    LogicalSurfaceTypeProcess::StartElement( name, attrs );
  }
  
  // Analogical to SAX endElement callback
  virtual void EndElement( const std::string& name )
  {
    LogicalSurfaceTypeProcess::EndElement( name );
  }
  
  // Analogical to SAX characters callback, it's called for ignorableWhitespace too!
  virtual void Characters( const std::string& )
  {
  }
  
  // Invoked whenever one of the daughter state processes has been popped-out of the state stack
  // The name passed-in as the argument is the name of the XML element for which that's been done
  virtual void StackPopNotify( const std::string& name)
  {
    LogicalSurfaceTypeProcess::StackPopNotify( name );
    SAXObject** so = Context()->GetTopObject();

    skinsurface* sobj  = dynamic_cast<skinsurface*>( m_obj );
    sobj->add_content( name, *so );

  }
  // The name of the state this object will process
  virtual const std::string& State() const
  {
    static std::string tag = "skinsurface";
    return tag;
  }
protected:
};

DECLARE_PROCESS_FACTORY(skinsurfaceProcess)
