package no.inspirado {
import no.inspirado.ServiceLocator;

import org.as3commons.lang.DictionaryUtils;
import org.flexunit.Assert;

public class ServiceLocatorTest {

    [After]
    [Before]
    public function cleanUp() : void{
        ServiceLocator.clean();
    }

    [Test]
    public function skalKunneLeggeTilServiceMedId() : void{
        Assert.assertEquals(0, DictionaryUtils.getKeys(ServiceLocator.services).length);
        ServiceLocator.addService(new VanillaObject("2"), "myVanilla");
        Assert.assertEquals(2, DictionaryUtils.getKeys(ServiceLocator.services).length);
    }

    [Test]
    public function skalKunneLeggeTilServiceMedImplementasjoner() : void{
        Assert.assertEquals(0, DictionaryUtils.getKeys(ServiceLocator.services).length);
        ServiceLocator.addService(new VanillaObjectWithImplementations(), "myVanilla");
        Assert.assertEquals(4, DictionaryUtils.getKeys(ServiceLocator.services).length);
    }

    [Test]
    public function skalHenteBasertPaaId() : void{
        var instance:VanillaObjectWithImplementations = new VanillaObjectWithImplementations();

        Assert.assertEquals(0, DictionaryUtils.getKeys(ServiceLocator.services).length);
        ServiceLocator.addService(instance, "myVanilla");
        Assert.assertEquals(instance, ServiceLocator.getServiceById("myVanilla"));
    }

    [Test]
    public function skalHenteBasertKlasse() : void{
        var instance:VanillaObject = new VanillaObject("5");

        Assert.assertEquals(0, DictionaryUtils.getKeys(ServiceLocator.services).length);
        ServiceLocator.addService(instance);
        Assert.assertEquals(instance, ServiceLocator.getServiceByType(VanillaObject));
    }

    [Test]
    public function skalHenteBasertPaaInterface() : void{
        var instance:VanillaObjectWithImplementations = new VanillaObjectWithImplementations();

        Assert.assertEquals(0, DictionaryUtils.getKeys(ServiceLocator.services).length);
        ServiceLocator.addService(instance);
        Assert.assertEquals(instance, ServiceLocator.getServiceByType(VanillaInterface1));
    }

    [Test]
    public function skalKjoreInit() : void{
        var instance:VanillaObject = new VanillaObject();

        ServiceLocator.addService(instance);
        Assert.assertEquals(false, ServiceLocator.getServiceByType(VanillaObject).hasDoneInit);
        ServiceLocator.configure();
        Assert.assertEquals(true, ServiceLocator.getServiceByType(VanillaObject).hasDoneInit);
        Assert.assertEquals(true, instance.hasDoneInit);
        Assert.assertEquals(false, ServiceLocator.getServiceByType(VanillaObject).hasInvokedMethodThatShouldNeverBeInvoked);
    }
}
}