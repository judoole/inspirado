package no.inspirado {
import flash.utils.Dictionary;
import flash.utils.describeType;

import no.inspirado.ApplicationContextError;

import org.as3commons.lang.ClassUtils;
import org.as3commons.lang.DictionaryUtils;
import org.as3commons.lang.ObjectUtils;
import org.as3commons.lang.StringUtils;

public dynamic class ServiceLocator {
    internal static var services:Dictionary = new Dictionary();
    public static var errorHandlerFunction:Function = throwError;
    public static var initMethods:Array = [];

    public static function addService(object:*, id:String = null):void {
        var clazz:Class = ClassUtils.forInstance(object);
        addReferenceIdFromId(id, object);
        addReferenceIdsFromImplementations(clazz, object);
        addReferenceIdFromSuperclass(clazz, object);
        addReferenceIdFromClassname(object);
        addInit(clazz, object);
    }

    public static function removeService(service:*):void {
        if (service is String) services[service] = null;
    }

    public static function getServiceById(id:String):* {
        if (services[id] == null) errorHandlerFunction("Could not find object with id " + id);
        else if (services[id] is ApplicationContextError) errorHandlerFunction(services[id]);
        else return services[id];
    }

    public static function getServiceByType(clazz:Class):* {
        var fullyQualifiedName:String = ClassUtils.getFullyQualifiedName(clazz, true);
        return getServiceById(fullyQualifiedName);
    }

    public static function configure():void {
        for each (var func:Function in initMethods) {
            func.apply();
        }
        initMethods = [];
    }

    public static function clean():void {
        services = new Dictionary();
        initMethods = [];
    }

    private static function addReferenceIdFromId(id:String, object:*):void {
        if (StringUtils.isNotEmpty(id)) instertObject(id, object);
        else {
            var clazz:Class = ClassUtils.forInstance(object);
            removeReferenceIdsFromImplementations(clazz);
            removeReferenceIdFromSuperclass(clazz);
            removeReferenceIdFromClassname(object);
        }
    }

    private static function addReferenceIdsFromImplementations(clazz:Class, object:*):void {
        var implementedInterfaces:Array = ClassUtils.getFullyQualifiedImplementedInterfaceNames(clazz, true);
        if (!(implementedInterfaces == null || implementedInterfaces.length == 0)) {
            for each(var objectId:String in implementedInterfaces) {
                instertObject(objectId, object);
            }
        }
    }

    private static function removeReferenceIdsFromImplementations(clazz:Class):void {
        var implementedInterfaces:Array = ClassUtils.getFullyQualifiedImplementedInterfaceNames(clazz, true);
        if (!(implementedInterfaces == null || implementedInterfaces.length == 0)) {
            for each(var objectId:String in implementedInterfaces) {
                delete services[objectId];
            }
        }
    }

    private static function addReferenceIdFromSuperclass(clazz:Class, object:*):void {
        var superclass:String = ClassUtils.getFullyQualifiedSuperClassName(clazz, true);
        if (superclass != ClassUtils.getFullyQualifiedName(Object, true)) {
            instertObject(superclass, object);
        }
    }

    private static function removeReferenceIdFromSuperclass(clazz:Class):void {
        var superclass:String = ClassUtils.getFullyQualifiedSuperClassName(clazz, true);
        if (superclass != ClassUtils.getFullyQualifiedName(Object, true)) {
            delete services[superclass];
        }
    }

    private static function addReferenceIdFromClassname(object:*):void {
        instertObject(ObjectUtils.getFullyQualifiedClassName(object, true), object);
    }

    private static function addInit(clazz:Class, object:*):void {
        var methods:XMLList = describeType(clazz).factory.method;
        for (var i:int = 0; i < methods.length(); i++) {
            if (methods[i].metadata.(@name == "Init").length() > 0) {
                var methodName:String = methods[i].@name;
                initMethods.push(object[methodName]);
            }
        }

    }

    private static function removeReferenceIdFromClassname(object:*):void {
        delete services[ObjectUtils.getFullyQualifiedClassName(object, true)];
    }

    private static function instertObject(id:String, object:*):void {
        if (DictionaryUtils.containsKey(services, id)) services[id] = new ApplicationContextError("An object with the id/class " + id + "  has more than 1 single reference.")
        else services[id] = object;
    }

    private static function throwError(error:*):void {
        if (error is String) throw new ApplicationContextError(error);
        else throw error;
    }
}
}